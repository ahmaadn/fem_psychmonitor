#pragma once
#include <vector>
#include <complex>
#include <cmath>
#include <cstring>
#include <algorithm>
#include <numeric>

// ─── Constants matching Python training config ───────────────────────────────
static constexpr int    SR          = 16000;
static constexpr double DURATION    = 3.0;
static constexpr int    N_MFCC      = 40;
static constexpr int    MAX_PAD_LEN = 128;
static constexpr int    N_FFT       = 2048;
static constexpr int    HOP_LENGTH  = 512;
static constexpr int    N_MELS      = 128;
static constexpr double F_MIN       = 0.0;
// F_MAX = SR/2 = 8000

static constexpr int TARGET_SAMPLES = static_cast<int>(SR * DURATION); // 48000
static constexpr int FEATURE_DIM    = N_MFCC * 3 + 1;                  // 121

// ─── FFT (Cooley-Tukey, in-place) ────────────────────────────────────────────
inline void fft(std::vector<std::complex<double>>& x) {
    const size_t N = x.size();
    if (N <= 1) return;
    // bit-reversal permutation
    for (size_t i = 1, j = 0; i < N; i++) {
        size_t bit = N >> 1;
        for (; j & bit; bit >>= 1) j ^= bit;
        j ^= bit;
        if (i < j) std::swap(x[i], x[j]);
    }
    for (size_t len = 2; len <= N; len <<= 1) {
        double ang = -2.0 * M_PI / static_cast<double>(len);
        std::complex<double> wlen(std::cos(ang), std::sin(ang));
        for (size_t i = 0; i < N; i += len) {
            std::complex<double> w(1.0, 0.0);
            for (size_t j = 0; j < len / 2; j++) {
                auto u = x[i + j];
                auto v = x[i + j + len / 2] * w;
                x[i + j]          = u + v;
                x[i + j + len/2]  = u - v;
                w *= wlen;
            }
        }
    }
}

// ─── Mel filterbank ──────────────────────────────────────────────────────────
inline double hz_to_mel(double hz) {
    return 2595.0 * std::log10(1.0 + hz / 700.0);
}
inline double mel_to_hz(double mel) {
    return 700.0 * (std::pow(10.0, mel / 2595.0) - 1.0);
}

// Returns [N_MELS x (N_FFT/2+1)] filterbank matrix
inline std::vector<std::vector<double>> build_mel_filterbank(
        int n_mels, int n_fft, int sr) {
    const int    n_bins = n_fft / 2 + 1;
    const double f_max  = sr / 2.0;
    const double m_min  = hz_to_mel(F_MIN);
    const double m_max  = hz_to_mel(f_max);

    // equally spaced mel points (n_mels + 2 points)
    std::vector<double> mel_points(n_mels + 2);
    for (int i = 0; i < n_mels + 2; i++)
        mel_points[i] = m_min + (m_max - m_min) * i / (n_mels + 1);

    // convert to hz then to FFT bin index
    std::vector<double> hz_points(n_mels + 2);
    for (int i = 0; i < n_mels + 2; i++)
        hz_points[i] = mel_to_hz(mel_points[i]);

    std::vector<double> bin_points(n_mels + 2);
    for (int i = 0; i < n_mels + 2; i++)
        bin_points[i] = std::floor((n_fft + 1) * hz_points[i] / sr);

    // build filterbank
    std::vector<std::vector<double>> fb(n_mels, std::vector<double>(n_bins, 0.0));
    for (int m = 1; m <= n_mels; m++) {
        int f_m_minus = static_cast<int>(bin_points[m - 1]);
        int f_m       = static_cast<int>(bin_points[m]);
        int f_m_plus  = static_cast<int>(bin_points[m + 1]);
        for (int k = f_m_minus; k < f_m && k < n_bins; k++) {
            double denom = (bin_points[m] - bin_points[m - 1]);
            if (denom > 0.0)
                fb[m - 1][k] = (k - bin_points[m - 1]) / denom;
        }
        for (int k = f_m; k <= f_m_plus && k < n_bins; k++) {
            double denom = (bin_points[m + 1] - bin_points[m]);
            if (denom > 0.0)
                fb[m - 1][k] = (bin_points[m + 1] - k) / denom;
        }
    }
    return fb;
}

// ─── DCT-II (orthonormal) ────────────────────────────────────────────────────
inline std::vector<double> dct2(const std::vector<double>& x, int n_out) {
    int N = static_cast<int>(x.size());
    std::vector<double> out(n_out);
    double scale0 = std::sqrt(1.0 / (4.0 * N));
    double scaleN = std::sqrt(1.0 / (2.0 * N));
    for (int k = 0; k < n_out; k++) {
        double sum = 0.0;
        for (int n = 0; n < N; n++)
            sum += x[n] * std::cos(M_PI * k * (2.0 * n + 1) / (2.0 * N));
        out[k] = sum * (k == 0 ? scale0 * 2.0 : scaleN * 2.0);
    }
    return out;
}

// ─── Delta features (librosa-compatible, width=9) ────────────────────────────
// data: [T x D], returns [T x D] delta
inline std::vector<std::vector<double>> compute_delta(
        const std::vector<std::vector<double>>& data, int width = 9) {
    int T = static_cast<int>(data.size());
    int D = static_cast<int>(data[0].size());
    int hw = width / 2;

    // normalizer = sum of squares of 1..hw
    double norm = 0.0;
    for (int i = 1; i <= hw; i++) norm += i * i;
    norm *= 2.0;

    std::vector<std::vector<double>> delta(T, std::vector<double>(D, 0.0));
    for (int t = 0; t < T; t++) {
        for (int d = 0; d < D; d++) {
            double val = 0.0;
            for (int n = 1; n <= hw; n++) {
                int t_plus  = std::min(t + n, T - 1);
                int t_minus = std::max(t - n, 0);
                val += n * (data[t_plus][d] - data[t_minus][d]);
            }
            delta[t][d] = val / norm;
        }
    }
    return delta;
}

// ─── Main extractor ──────────────────────────────────────────────────────────
// Returns flattened [MAX_PAD_LEN * FEATURE_DIM] float32 array (row-major)
// Caller must allocate output of size MAX_PAD_LEN * FEATURE_DIM
extern "C" {

void extract_features(
        const float* audio_in,   // 48000 float32 samples (already 16kHz)
        int          n_samples,  // must be 48000
        float*       output      // [MAX_PAD_LEN * FEATURE_DIM] = [128 * 121]
) {
    // ── 1. Copy, pad/crop ────────────────────────────────────────────────────
    std::vector<double> audio(audio_in, audio_in + n_samples);
    audio.resize(TARGET_SAMPLES, 0.0);

    // ── 1b. Stationary spectral gating (approx. noisereduce stationary=True) ─
    // Estimate noise profile from quietest 10% frames by RMS, then attenuate
    // bins that are not significantly above the noise floor.
    {
        const int nr_hop = HOP_LENGTH;
        const int nr_fft = N_FFT;
        const int nr_bins = nr_fft / 2 + 1;
        const int nr_frames = 1 + (TARGET_SAMPLES - nr_fft) / nr_hop;
        if (nr_frames > 4) {
            std::vector<double> frame_rms(nr_frames, 0.0);
            std::vector<std::vector<double>> power(nr_frames,
                std::vector<double>(nr_bins, 0.0));
            std::vector<std::complex<double>> fft_buf(nr_fft);
            std::vector<double> win(nr_fft);
            for (int i = 0; i < nr_fft; i++)
                win[i] = 0.54 - 0.46 * std::cos(2.0 * M_PI * i / (nr_fft - 1));

            for (int t = 0; t < nr_frames; t++) {
                int start = t * nr_hop;
                double energy = 0.0;
                for (int i = 0; i < nr_fft; i++) {
                    double s = audio[start + i] * win[i];
                    fft_buf[i] = std::complex<double>(s, 0.0);
                    energy += s * s;
                }
                frame_rms[t] = std::sqrt(energy / nr_fft);
                fft(fft_buf);
                for (int k = 0; k < nr_bins; k++)
                    power[t][k] = std::norm(fft_buf[k]);
            }

            // Quietest 10% frames → noise profile
            std::vector<int> order(nr_frames);
            std::iota(order.begin(), order.end(), 0);
            std::sort(order.begin(), order.end(),
                [&](int a, int b) { return frame_rms[a] < frame_rms[b]; });
            int n_noise = std::max(1, nr_frames / 10);
            std::vector<double> noise_prof(nr_bins, 0.0);
            for (int i = 0; i < n_noise; i++) {
                int t = order[i];
                for (int k = 0; k < nr_bins; k++)
                    noise_prof[k] += power[t][k];
            }
            for (int k = 0; k < nr_bins; k++)
                noise_prof[k] = noise_prof[k] / n_noise + 1e-12;

            // Soft mask + OLA reconstruct
            std::vector<double> out(TARGET_SAMPLES, 0.0);
            std::vector<double> wsum(TARGET_SAMPLES, 0.0);
            const double prop_decrease = 0.8;
            for (int t = 0; t < nr_frames; t++) {
                int start = t * nr_hop;
                for (int i = 0; i < nr_fft; i++) {
                    double s = audio[start + i] * win[i];
                    fft_buf[i] = std::complex<double>(s, 0.0);
                }
                fft(fft_buf);
                for (int k = 0; k < nr_bins; k++) {
                    double p = std::norm(fft_buf[k]);
                    double snr = p / noise_prof[k];
                    double mask = snr > 2.0 ? 1.0 : std::max(0.05, snr / 2.0);
                    mask = 1.0 - prop_decrease * (1.0 - mask);
                    fft_buf[k] *= mask;
                    if (k > 0 && k < nr_bins - 1)
                        fft_buf[nr_fft - k] = std::conj(fft_buf[k]);
                }
                // inverse FFT via conjugate + forward FFT
                for (auto& c : fft_buf) c = std::conj(c);
                fft(fft_buf);
                for (int i = 0; i < nr_fft; i++) {
                    double s = std::real(fft_buf[i]) / nr_fft * win[i];
                    out[start + i] += s;
                    wsum[start + i] += win[i] * win[i];
                }
            }
            for (int i = 0; i < TARGET_SAMPLES; i++) {
                if (wsum[i] > 1e-9) audio[i] = out[i] / wsum[i];
            }
        }
    }

    // ── 1c. Peak normalization (after NR, before MFCC) ───────────────────────
    double max_abs = 0.0;
    for (auto v : audio) max_abs = std::max(max_abs, std::abs(v));
    if (max_abs > 0.0)
        for (auto& v : audio) v /= max_abs;

    // ── 2. Pre-emphasis (librosa uses none by default, skip) ─────────────────

    // ── 3. Framing ───────────────────────────────────────────────────────────
    const int n_frames = 1 + (TARGET_SAMPLES - N_FFT) / HOP_LENGTH; // ~91
    const int n_bins   = N_FFT / 2 + 1;                              // 1025

    // Build mel filterbank once
    auto mel_fb = build_mel_filterbank(N_MELS, N_FFT, SR);

    // FFT workspace (next power of 2 >= N_FFT → N_FFT itself is 2048)
    std::vector<std::complex<double>> frame_fft(N_FFT);

    // Hamming window
    std::vector<double> window(N_FFT);
    for (int i = 0; i < N_FFT; i++)
        window[i] = 0.54 - 0.46 * std::cos(2.0 * M_PI * i / (N_FFT - 1));

    // [n_frames x N_MELS] log mel spectrogram
    std::vector<std::vector<double>> log_mel(n_frames, std::vector<double>(N_MELS, 0.0));

    // [n_frames x 1] ZCR
    std::vector<double> zcr_frames(n_frames, 0.0);

    for (int t = 0; t < n_frames; t++) {
        int start = t * HOP_LENGTH;

        // apply window + fill FFT buffer
        for (int i = 0; i < N_FFT; i++) {
            int idx = start + i;
            double s = (idx < TARGET_SAMPLES) ? audio[idx] : 0.0;
            frame_fft[i] = std::complex<double>(s * window[i], 0.0);
        }

        fft(frame_fft);

        // power spectrum
        std::vector<double> power(n_bins);
        for (int i = 0; i < n_bins; i++)
            power[i] = std::norm(frame_fft[i]); // |.|^2

        // mel filterbank → log
        for (int m = 0; m < N_MELS; m++) {
            double mel_energy = 0.0;
            for (int k = 0; k < n_bins; k++)
                mel_energy += mel_fb[m][k] * power[k];
            log_mel[t][m] = std::log(mel_energy + 1e-9);
        }

        // ZCR for this frame
        int zcr_start = start;
        int zcr_len   = std::min(N_FFT, TARGET_SAMPLES - zcr_start);
        if (zcr_len > 1) {
            int crossings = 0;
            for (int i = zcr_start + 1; i < zcr_start + zcr_len; i++) {
                if ((audio[i] >= 0.0) != (audio[i - 1] >= 0.0)) crossings++;
            }
            zcr_frames[t] = static_cast<double>(crossings) / (zcr_len - 1);
        }
    }

    // ── 4. DCT → MFCC [n_frames x N_MFCC] ──────────────────────────────────
    std::vector<std::vector<double>> mfcc(n_frames, std::vector<double>(N_MFCC));
    for (int t = 0; t < n_frames; t++)
        mfcc[t] = dct2(log_mel[t], N_MFCC);

    // ── 5. Delta & Delta2 ────────────────────────────────────────────────────
    auto delta  = compute_delta(mfcc);
    auto delta2 = compute_delta(delta);

    // ── 6. Concatenate [mfcc | delta | delta2 | zcr] = [T x 121] ────────────
    // then pad/crop to MAX_PAD_LEN rows
    int T_out = std::min(n_frames, MAX_PAD_LEN);

    // ── 7. Per-column normalization + write output ───────────────────────────
    // First build un-normalized feature matrix [MAX_PAD_LEN x FEATURE_DIM]
    // (zero-padded if T_out < MAX_PAD_LEN)
    // We normalize in place column-wise.

    // Temp buffer
    std::vector<std::vector<double>> features(MAX_PAD_LEN,
            std::vector<double>(FEATURE_DIM, 0.0));

    for (int t = 0; t < T_out; t++) {
        for (int d = 0; d < N_MFCC; d++)
            features[t][d] = mfcc[t][d];
        for (int d = 0; d < N_MFCC; d++)
            features[t][N_MFCC + d] = delta[t][d];
        for (int d = 0; d < N_MFCC; d++)
            features[t][N_MFCC * 2 + d] = delta2[t][d];
        features[t][N_MFCC * 3] = zcr_frames[t];
    }

    // normalize each column (i) with mean/std over MAX_PAD_LEN rows
    for (int i = 0; i < FEATURE_DIM; i++) {
        double mean = 0.0;
        for (int t = 0; t < MAX_PAD_LEN; t++) mean += features[t][i];
        mean /= MAX_PAD_LEN;

        double var = 0.0;
        for (int t = 0; t < MAX_PAD_LEN; t++) {
            double diff = features[t][i] - mean;
            var += diff * diff;
        }
        double std_dev = std::sqrt(var / MAX_PAD_LEN);

        for (int t = 0; t < MAX_PAD_LEN; t++) {
            output[t * FEATURE_DIM + i] = (std_dev > 1e-9)
                ? static_cast<float>((features[t][i] - mean) / std_dev)
                : 0.0f;
        }
    }
}

// Convenience: returns required output buffer size
int feature_output_size() { return MAX_PAD_LEN * FEATURE_DIM; }

} // extern "C"
