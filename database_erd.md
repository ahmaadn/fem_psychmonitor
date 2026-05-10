# Application Database ERD

Berikut adalah *Entity-Relationship Diagram* (ERD) dari sistem Fem Psychmonitor. Skema ini dirancang berdasarkan model-model data Dart yang ada di sistem, dan telah dipetakan menjadi struktur tabel relasional yang siap diimplementasikan ke dalam SQLite atau Online Backend.

```mermaid
erDiagram
    USERS {
        VARCHAR id PK
        VARCHAR full_name
        VARCHAR email
        VARCHAR phone "NULL"
        DATETIME date_of_birth "NULL"
        VARCHAR avatar_url "NULL"
        DATETIME created_at
        VARCHAR mbti_result "NULL"
        INT psych_score "NULL"
        VARCHAR psych_class "NULL"
    }

    DETECTION_SESSIONS {
        VARCHAR id PK
        VARCHAR user_id FK
        DATETIME started_at
        DATETIME stopped_at
        VARCHAR source_type "ENUM('live', 'upload')"
        VARCHAR audio_file_path "NULL"
        VARCHAR dominant_emotion "ENUM"
        FLOAT dominant_confidence
    }

    DETECTION_RESULTS {
        VARCHAR id PK
        VARCHAR session_id FK
        FLOAT start_sec
        FLOAT end_sec
        VARCHAR label "ENUM"
        FLOAT confidence
        JSON all_probs "List<double> Probabilities"
    }

    MBTI_QUESTIONS {
        INT id PK
        VARCHAR code
        VARCHAR dimension
        TEXT question_en "LocalizedString"
        TEXT question_id "LocalizedString"
    }

    MBTI_OPTIONS {
        INT id PK
        INT question_id FK
        VARCHAR code
        TEXT answer_en "LocalizedString"
        TEXT answer_id "LocalizedString"
        VARCHAR type "M, B, T, I traits"
    }

    PSYCH_QUESTIONS {
        INT id PK
        VARCHAR code
        VARCHAR category_en "LocalizedString"
        VARCHAR category_id "LocalizedString"
        TEXT question_en "LocalizedString"
        TEXT question_id "LocalizedString"
    }

    PSYCH_OPTIONS {
        INT id PK
        INT question_id FK
        VARCHAR code
        TEXT answer_en "LocalizedString"
        TEXT answer_id "LocalizedString"
        INT score
    }

    PSYCH_CLASSES {
        INT class_level PK
        VARCHAR class_name_en "LocalizedString"
        VARCHAR class_name_id "LocalizedString"
        VARCHAR display_range
        VARCHAR score_range
        TEXT description_en "LocalizedString"
        TEXT description_id "LocalizedString"
        TEXT recommendation_en "LocalizedString"
        TEXT recommendation_id "LocalizedString"
    }

    SARAN_RECOMMENDATIONS {
        VARCHAR mbti_type PK
        VARCHAR alias
        VARCHAR group
        JSON emotions_json "SaranEmotions mapping"
    }

    %% Relationships
    USERS ||--o{ DETECTION_SESSIONS : "memiliki"
    DETECTION_SESSIONS ||--|{ DETECTION_RESULTS : "berisi"
    
    MBTI_QUESTIONS ||--|{ MBTI_OPTIONS : "memiliki"
    PSYCH_QUESTIONS ||--|{ PSYCH_OPTIONS : "memiliki"

    %% Logical Relationships (tanpa FK fisik langsung, namun berhubungan)
    USERS }o--o| PSYCH_CLASSES : "mendapat hasil"
    USERS }o--o| SARAN_RECOMMENDATIONS : "mendapat rekomendasi"
```

## Deskripsi Tabel & Standarisasi

### Transaksional (Core Data)
1. **`USERS`**: Menyimpan identitas pengguna dan agregasi hasil *assessment* (MBTI & Nilai Mental Health) setelah proses onboarding selesai.
2. **`DETECTION_SESSIONS`**: Mewakili sesi rekaman atau unggah audio (*one-to-many* ke *users*). Memiliki metadata kapan sesi dimulai/diakhiri serta emosi dominan keseluruhan.
3. **`DETECTION_RESULTS`**: Mencatat *timeline* detik-per-detik hasil inference AI. `all_probs` dapat disimpan sebagai array JSON (Text di SQLite) untuk fleksibilitas.

### Master / Reference Data (Assessment Content)
Sistem kuesioner (*onboarding*) memiliki model *LocalizedString* untuk terjemahan EN dan ID, yang pada tabel di atas dipisahkan menjadi kolom `_en` dan `_id` untuk standarisasi lokalisasi dalam RDBMS.
1. **`MBTI_QUESTIONS` & `MBTI_OPTIONS`**: Menyimpan master pertanyaan tes MBTI beserta opsi jawabannya, termasuk *trait type* (E, I, S, N, T, F, P, J) yang digunakan untuk kalkulasi.
2. **`PSYCH_QUESTIONS` & `PSYCH_OPTIONS`**: Menyimpan master pertanyaan *Womens Mental Health Assessment* beserta bobot skor dari setiap jawaban.
3. **`PSYCH_CLASSES`**: Menyimpan standar kelas *scoring* (seperti Normal, Depresi Ringan, Depresi Sedang, dst) serta rekomendasi aksinya berdasarkan range poin akhir.
4. **`SARAN_RECOMMENDATIONS`**: Memetakan *MBTI_Type* terhadap karakteristik emosional (`happy`, `fear`, `sad`, `disgust`, `angry`, `neutral`) untuk menghasilkan *insight* ke pengguna.

Tabel dan *field* ini sudah dikonfirmasi mencakup seluruh model yang didefinisikan pada sistem Anda (`UserModel`, `DetectionSessionModel`, `DetectionResultModel`, `MbtiModel`, `PsychModel`, `SaranModel`).
