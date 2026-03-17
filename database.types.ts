export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.1"
  }
  public: {
    Tables: {
      en_chapters: {
        Row: {
          audio_url: string | null
          content: string | null
          content_multi: Json | null
          created_at: string
          description: string | null
          duration: number | null
          id: number
          long_format_id: number | null
          order_id: number | null
          reviewed: number | null
          title: string | null
          title_dt: string | null
          title_en: string | null
          title_ge: string | null
          title_it: string | null
          title_jp: string | null
          title_pt: string | null
          title_sp: string | null
        }
        Insert: {
          audio_url?: string | null
          content?: string | null
          content_multi?: Json | null
          created_at?: string
          description?: string | null
          duration?: number | null
          id?: number
          long_format_id?: number | null
          order_id?: number | null
          reviewed?: number | null
          title?: string | null
          title_dt?: string | null
          title_en?: string | null
          title_ge?: string | null
          title_it?: string | null
          title_jp?: string | null
          title_pt?: string | null
          title_sp?: string | null
        }
        Update: {
          audio_url?: string | null
          content?: string | null
          content_multi?: Json | null
          created_at?: string
          description?: string | null
          duration?: number | null
          id?: number
          long_format_id?: number | null
          order_id?: number | null
          reviewed?: number | null
          title?: string | null
          title_dt?: string | null
          title_en?: string | null
          title_ge?: string | null
          title_it?: string | null
          title_jp?: string | null
          title_pt?: string | null
          title_sp?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "chapters_fr_long_format_id_fkey"
            columns: ["long_format_id"]
            isOneToOne: false
            referencedRelation: "en_content"
            referencedColumns: ["id"]
          },
        ]
      }
      en_content: {
        Row: {
          audio_url: string | null
          author: string | null
          category_1: string | null
          category_2: string | null
          category_3: string | null
          content: string | null
          content_multi: Json | null
          content_type: number
          created_at: string
          description: string | null
          description_dt: string | null
          description_en: string | null
          description_ge: string | null
          description_it: string | null
          description_jp: string | null
          description_pt: string | null
          description_sp: string | null
          id: number
          img_url: string | null
          is_free: boolean | null
          level: string | null
          title: string | null
        }
        Insert: {
          audio_url?: string | null
          author?: string | null
          category_1?: string | null
          category_2?: string | null
          category_3?: string | null
          content?: string | null
          content_multi?: Json | null
          content_type: number
          created_at?: string
          description?: string | null
          description_dt?: string | null
          description_en?: string | null
          description_ge?: string | null
          description_it?: string | null
          description_jp?: string | null
          description_pt?: string | null
          description_sp?: string | null
          id?: number
          img_url?: string | null
          is_free?: boolean | null
          level?: string | null
          title?: string | null
        }
        Update: {
          audio_url?: string | null
          author?: string | null
          category_1?: string | null
          category_2?: string | null
          category_3?: string | null
          content?: string | null
          content_multi?: Json | null
          content_type?: number
          created_at?: string
          description?: string | null
          description_dt?: string | null
          description_en?: string | null
          description_ge?: string | null
          description_it?: string | null
          description_jp?: string | null
          description_pt?: string | null
          description_sp?: string | null
          id?: number
          img_url?: string | null
          is_free?: boolean | null
          level?: string | null
          title?: string | null
        }
        Relationships: []
      }
      en_flashcards: {
        Row: {
          audio_url: string | null
          chapter_id: number | null
          content_id: number | null
          created_at: string
          example: string | null
          example_translation: string | null
          finished_datetime: string | null
          function: string | null
          id: number
          status: string | null
          text: string | null
          text_translation: string | null
          user_id: string | null
          vocabulary_id: number | null
        }
        Insert: {
          audio_url?: string | null
          chapter_id?: number | null
          content_id?: number | null
          created_at?: string
          example?: string | null
          example_translation?: string | null
          finished_datetime?: string | null
          function?: string | null
          id?: number
          status?: string | null
          text?: string | null
          text_translation?: string | null
          user_id?: string | null
          vocabulary_id?: number | null
        }
        Update: {
          audio_url?: string | null
          chapter_id?: number | null
          content_id?: number | null
          created_at?: string
          example?: string | null
          example_translation?: string | null
          finished_datetime?: string | null
          function?: string | null
          id?: number
          status?: string | null
          text?: string | null
          text_translation?: string | null
          user_id?: string | null
          vocabulary_id?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "flashcards_fr_content_id_fkey"
            columns: ["content_id"]
            isOneToOne: false
            referencedRelation: "en_content"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "flashcards_fr_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "flashcards_fr_vocabulary_id_fkey"
            columns: ["vocabulary_id"]
            isOneToOne: false
            referencedRelation: "en_vocabulary"
            referencedColumns: ["id"]
          },
        ]
      }
      en_progress: {
        Row: {
          chapter_id: number | null
          content_id: number | null
          content_type: number | null
          created_at: string
          finished_datetime: string | null
          id: number
          is_liked: boolean | null
          reading_status: string | null
          started_datetime: string | null
          user_id: string | null
        }
        Insert: {
          chapter_id?: number | null
          content_id?: number | null
          content_type?: number | null
          created_at?: string
          finished_datetime?: string | null
          id?: number
          is_liked?: boolean | null
          reading_status?: string | null
          started_datetime?: string | null
          user_id?: string | null
        }
        Update: {
          chapter_id?: number | null
          content_id?: number | null
          content_type?: number | null
          created_at?: string
          finished_datetime?: string | null
          id?: number
          is_liked?: boolean | null
          reading_status?: string | null
          started_datetime?: string | null
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "progress_fr_content_id_fkey"
            columns: ["content_id"]
            isOneToOne: false
            referencedRelation: "en_content"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "progress_fr_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      en_quiz_models: {
        Row: {
          answer_1: string | null
          answer_2: string | null
          answer_3: string | null
          answer_4: string | null
          chapter_id: number | null
          correct_answer: number
          created_at: string
          id: number
          question: string | null
          quiz_id: number | null
          reference_id: number | null
          tip: string | null
          type: number | null
        }
        Insert: {
          answer_1?: string | null
          answer_2?: string | null
          answer_3?: string | null
          answer_4?: string | null
          chapter_id?: number | null
          correct_answer: number
          created_at?: string
          id?: number
          question?: string | null
          quiz_id?: number | null
          reference_id?: number | null
          tip?: string | null
          type?: number | null
        }
        Update: {
          answer_1?: string | null
          answer_2?: string | null
          answer_3?: string | null
          answer_4?: string | null
          chapter_id?: number | null
          correct_answer?: number
          created_at?: string
          id?: number
          question?: string | null
          quiz_id?: number | null
          reference_id?: number | null
          tip?: string | null
          type?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "quizz_models_fr_chapter_id_fkey"
            columns: ["chapter_id"]
            isOneToOne: false
            referencedRelation: "en_chapters"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "quizz_models_fr_reference_id_fkey"
            columns: ["reference_id"]
            isOneToOne: false
            referencedRelation: "en_content"
            referencedColumns: ["id"]
          },
        ]
      }
      en_quiz_results: {
        Row: {
          created_at: string
          filled_out: boolean | null
          finished_datetime: string | null
          id: number
          number_correct_answers: number | null
          quiz_id: number | null
          reference_id: number | null
          type: number | null
          user_id: string | null
        }
        Insert: {
          created_at?: string
          filled_out?: boolean | null
          finished_datetime?: string | null
          id?: number
          number_correct_answers?: number | null
          quiz_id?: number | null
          reference_id?: number | null
          type?: number | null
          user_id?: string | null
        }
        Update: {
          created_at?: string
          filled_out?: boolean | null
          finished_datetime?: string | null
          id?: number
          number_correct_answers?: number | null
          quiz_id?: number | null
          reference_id?: number | null
          type?: number | null
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "quiz_results_fr_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "quiz_results_quiz_id_fkey"
            columns: ["quiz_id"]
            isOneToOne: false
            referencedRelation: "en_quiz_models"
            referencedColumns: ["id"]
          },
        ]
      }
      en_vocabulary: {
        Row: {
          audio_url: string | null
          chapter_id: number | null
          content_type: number | null
          created_at: string
          example: string | null
          example_dt: string | null
          example_en: string | null
          example_ge: string | null
          example_it: string | null
          example_jp: string | null
          example_pt: string | null
          example_sp: string | null
          function: string | null
          id: number
          reference_id: number | null
          text: string | null
          text_dt: string | null
          text_en: string | null
          text_ge: string | null
          text_it: string | null
          text_jp: string | null
          text_pt: string | null
          text_sp: string | null
        }
        Insert: {
          audio_url?: string | null
          chapter_id?: number | null
          content_type?: number | null
          created_at?: string
          example?: string | null
          example_dt?: string | null
          example_en?: string | null
          example_ge?: string | null
          example_it?: string | null
          example_jp?: string | null
          example_pt?: string | null
          example_sp?: string | null
          function?: string | null
          id?: number
          reference_id?: number | null
          text?: string | null
          text_dt?: string | null
          text_en?: string | null
          text_ge?: string | null
          text_it?: string | null
          text_jp?: string | null
          text_pt?: string | null
          text_sp?: string | null
        }
        Update: {
          audio_url?: string | null
          chapter_id?: number | null
          content_type?: number | null
          created_at?: string
          example?: string | null
          example_dt?: string | null
          example_en?: string | null
          example_ge?: string | null
          example_it?: string | null
          example_jp?: string | null
          example_pt?: string | null
          example_sp?: string | null
          function?: string | null
          id?: number
          reference_id?: number | null
          text?: string | null
          text_dt?: string | null
          text_en?: string | null
          text_ge?: string | null
          text_it?: string | null
          text_jp?: string | null
          text_pt?: string | null
          text_sp?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "vocabulary_fr_chapter_id_fkey"
            columns: ["chapter_id"]
            isOneToOne: false
            referencedRelation: "en_chapters"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "vocabulary_fr_reference_id_fkey1"
            columns: ["reference_id"]
            isOneToOne: false
            referencedRelation: "en_content"
            referencedColumns: ["id"]
          },
        ]
      }
      es_chapters: {
        Row: {
          audio_url: string | null
          content: string | null
          content_multi: Json | null
          created_at: string
          description: string | null
          duration: number | null
          id: number
          long_format_id: number | null
          order_id: number | null
          reviewed: number | null
          title: string | null
          title_dt: string | null
          title_en: string | null
          title_ge: string | null
          title_it: string | null
          title_jp: string | null
          title_pt: string | null
          title_sp: string | null
        }
        Insert: {
          audio_url?: string | null
          content?: string | null
          content_multi?: Json | null
          created_at?: string
          description?: string | null
          duration?: number | null
          id?: number
          long_format_id?: number | null
          order_id?: number | null
          reviewed?: number | null
          title?: string | null
          title_dt?: string | null
          title_en?: string | null
          title_ge?: string | null
          title_it?: string | null
          title_jp?: string | null
          title_pt?: string | null
          title_sp?: string | null
        }
        Update: {
          audio_url?: string | null
          content?: string | null
          content_multi?: Json | null
          created_at?: string
          description?: string | null
          duration?: number | null
          id?: number
          long_format_id?: number | null
          order_id?: number | null
          reviewed?: number | null
          title?: string | null
          title_dt?: string | null
          title_en?: string | null
          title_ge?: string | null
          title_it?: string | null
          title_jp?: string | null
          title_pt?: string | null
          title_sp?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "chapters_fr_long_format_id_fkey"
            columns: ["long_format_id"]
            isOneToOne: false
            referencedRelation: "es_content"
            referencedColumns: ["id"]
          },
        ]
      }
      es_content: {
        Row: {
          audio_url: string | null
          author: string | null
          category_1: string | null
          category_2: string | null
          category_3: string | null
          content: string | null
          content_multi: Json | null
          content_type: number
          created_at: string
          description: string | null
          description_dt: string | null
          description_en: string | null
          description_ge: string | null
          description_it: string | null
          description_jp: string | null
          description_pt: string | null
          description_sp: string | null
          id: number
          img_url: string | null
          is_free: boolean | null
          level: string | null
          title: string | null
        }
        Insert: {
          audio_url?: string | null
          author?: string | null
          category_1?: string | null
          category_2?: string | null
          category_3?: string | null
          content?: string | null
          content_multi?: Json | null
          content_type: number
          created_at?: string
          description?: string | null
          description_dt?: string | null
          description_en?: string | null
          description_ge?: string | null
          description_it?: string | null
          description_jp?: string | null
          description_pt?: string | null
          description_sp?: string | null
          id?: number
          img_url?: string | null
          is_free?: boolean | null
          level?: string | null
          title?: string | null
        }
        Update: {
          audio_url?: string | null
          author?: string | null
          category_1?: string | null
          category_2?: string | null
          category_3?: string | null
          content?: string | null
          content_multi?: Json | null
          content_type?: number
          created_at?: string
          description?: string | null
          description_dt?: string | null
          description_en?: string | null
          description_ge?: string | null
          description_it?: string | null
          description_jp?: string | null
          description_pt?: string | null
          description_sp?: string | null
          id?: number
          img_url?: string | null
          is_free?: boolean | null
          level?: string | null
          title?: string | null
        }
        Relationships: []
      }
      es_flashcards: {
        Row: {
          audio_url: string | null
          chapter_id: number | null
          content_id: number | null
          created_at: string
          example: string | null
          example_translation: string | null
          finished_datetime: string | null
          function: string | null
          id: number
          status: string | null
          text: string | null
          text_translation: string | null
          user_id: string | null
          vocabulary_id: number | null
        }
        Insert: {
          audio_url?: string | null
          chapter_id?: number | null
          content_id?: number | null
          created_at?: string
          example?: string | null
          example_translation?: string | null
          finished_datetime?: string | null
          function?: string | null
          id?: number
          status?: string | null
          text?: string | null
          text_translation?: string | null
          user_id?: string | null
          vocabulary_id?: number | null
        }
        Update: {
          audio_url?: string | null
          chapter_id?: number | null
          content_id?: number | null
          created_at?: string
          example?: string | null
          example_translation?: string | null
          finished_datetime?: string | null
          function?: string | null
          id?: number
          status?: string | null
          text?: string | null
          text_translation?: string | null
          user_id?: string | null
          vocabulary_id?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "flashcards_fr_content_id_fkey"
            columns: ["content_id"]
            isOneToOne: false
            referencedRelation: "es_content"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "flashcards_fr_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "flashcards_fr_vocabulary_id_fkey"
            columns: ["vocabulary_id"]
            isOneToOne: false
            referencedRelation: "es_vocabulary"
            referencedColumns: ["id"]
          },
        ]
      }
      es_progress: {
        Row: {
          chapter_id: number | null
          content_id: number | null
          content_type: number | null
          created_at: string
          finished_datetime: string | null
          id: number
          is_liked: boolean | null
          reading_status: string | null
          started_datetime: string | null
          user_id: string | null
        }
        Insert: {
          chapter_id?: number | null
          content_id?: number | null
          content_type?: number | null
          created_at?: string
          finished_datetime?: string | null
          id?: number
          is_liked?: boolean | null
          reading_status?: string | null
          started_datetime?: string | null
          user_id?: string | null
        }
        Update: {
          chapter_id?: number | null
          content_id?: number | null
          content_type?: number | null
          created_at?: string
          finished_datetime?: string | null
          id?: number
          is_liked?: boolean | null
          reading_status?: string | null
          started_datetime?: string | null
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "progress_fr_content_id_fkey"
            columns: ["content_id"]
            isOneToOne: false
            referencedRelation: "es_content"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "progress_fr_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      es_quiz_models: {
        Row: {
          answer_1: string | null
          answer_2: string | null
          answer_3: string | null
          answer_4: string | null
          chapter_id: number | null
          correct_answer: number
          created_at: string
          id: number
          question: string | null
          quiz_id: number | null
          reference_id: number | null
          tip: string | null
          type: number | null
        }
        Insert: {
          answer_1?: string | null
          answer_2?: string | null
          answer_3?: string | null
          answer_4?: string | null
          chapter_id?: number | null
          correct_answer: number
          created_at?: string
          id?: number
          question?: string | null
          quiz_id?: number | null
          reference_id?: number | null
          tip?: string | null
          type?: number | null
        }
        Update: {
          answer_1?: string | null
          answer_2?: string | null
          answer_3?: string | null
          answer_4?: string | null
          chapter_id?: number | null
          correct_answer?: number
          created_at?: string
          id?: number
          question?: string | null
          quiz_id?: number | null
          reference_id?: number | null
          tip?: string | null
          type?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "quizz_models_fr_chapter_id_fkey"
            columns: ["chapter_id"]
            isOneToOne: false
            referencedRelation: "es_chapters"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "quizz_models_fr_reference_id_fkey"
            columns: ["reference_id"]
            isOneToOne: false
            referencedRelation: "es_content"
            referencedColumns: ["id"]
          },
        ]
      }
      es_quiz_results: {
        Row: {
          created_at: string
          filled_out: boolean | null
          finished_datetime: string | null
          id: number
          number_correct_answers: number | null
          quiz_id: number | null
          reference_id: number | null
          type: number | null
          user_id: string | null
        }
        Insert: {
          created_at?: string
          filled_out?: boolean | null
          finished_datetime?: string | null
          id?: number
          number_correct_answers?: number | null
          quiz_id?: number | null
          reference_id?: number | null
          type?: number | null
          user_id?: string | null
        }
        Update: {
          created_at?: string
          filled_out?: boolean | null
          finished_datetime?: string | null
          id?: number
          number_correct_answers?: number | null
          quiz_id?: number | null
          reference_id?: number | null
          type?: number | null
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "quiz_results_fr_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "quiz_results_quiz_id_fkey"
            columns: ["quiz_id"]
            isOneToOne: false
            referencedRelation: "es_quiz_models"
            referencedColumns: ["id"]
          },
        ]
      }
      es_vocabulary: {
        Row: {
          audio_url: string | null
          chapter_id: number | null
          content_type: number | null
          created_at: string
          example: string | null
          example_dt: string | null
          example_en: string | null
          example_ge: string | null
          example_it: string | null
          example_jp: string | null
          example_pt: string | null
          example_sp: string | null
          function: string | null
          id: number
          reference_id: number | null
          text: string | null
          text_dt: string | null
          text_en: string | null
          text_ge: string | null
          text_it: string | null
          text_jp: string | null
          text_pt: string | null
          text_sp: string | null
        }
        Insert: {
          audio_url?: string | null
          chapter_id?: number | null
          content_type?: number | null
          created_at?: string
          example?: string | null
          example_dt?: string | null
          example_en?: string | null
          example_ge?: string | null
          example_it?: string | null
          example_jp?: string | null
          example_pt?: string | null
          example_sp?: string | null
          function?: string | null
          id?: number
          reference_id?: number | null
          text?: string | null
          text_dt?: string | null
          text_en?: string | null
          text_ge?: string | null
          text_it?: string | null
          text_jp?: string | null
          text_pt?: string | null
          text_sp?: string | null
        }
        Update: {
          audio_url?: string | null
          chapter_id?: number | null
          content_type?: number | null
          created_at?: string
          example?: string | null
          example_dt?: string | null
          example_en?: string | null
          example_ge?: string | null
          example_it?: string | null
          example_jp?: string | null
          example_pt?: string | null
          example_sp?: string | null
          function?: string | null
          id?: number
          reference_id?: number | null
          text?: string | null
          text_dt?: string | null
          text_en?: string | null
          text_ge?: string | null
          text_it?: string | null
          text_jp?: string | null
          text_pt?: string | null
          text_sp?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "vocabulary_fr_chapter_id_fkey"
            columns: ["chapter_id"]
            isOneToOne: false
            referencedRelation: "es_chapters"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "vocabulary_fr_reference_id_fkey1"
            columns: ["reference_id"]
            isOneToOne: false
            referencedRelation: "es_content"
            referencedColumns: ["id"]
          },
        ]
      }
      fr_chapters: {
        Row: {
          audio_url: string | null
          content: string | null
          content_multi: Json | null
          created_at: string
          description: string | null
          duration: number | null
          id: number
          long_format_id: number | null
          order_id: number | null
          reviewed: number | null
          title: string | null
          title_dt: string | null
          title_en: string | null
          title_ge: string | null
          title_it: string | null
          title_jp: string | null
          title_pt: string | null
          title_sp: string | null
        }
        Insert: {
          audio_url?: string | null
          content?: string | null
          content_multi?: Json | null
          created_at?: string
          description?: string | null
          duration?: number | null
          id?: number
          long_format_id?: number | null
          order_id?: number | null
          reviewed?: number | null
          title?: string | null
          title_dt?: string | null
          title_en?: string | null
          title_ge?: string | null
          title_it?: string | null
          title_jp?: string | null
          title_pt?: string | null
          title_sp?: string | null
        }
        Update: {
          audio_url?: string | null
          content?: string | null
          content_multi?: Json | null
          created_at?: string
          description?: string | null
          duration?: number | null
          id?: number
          long_format_id?: number | null
          order_id?: number | null
          reviewed?: number | null
          title?: string | null
          title_dt?: string | null
          title_en?: string | null
          title_ge?: string | null
          title_it?: string | null
          title_jp?: string | null
          title_pt?: string | null
          title_sp?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "chapters_fr_long_format_id_fkey"
            columns: ["long_format_id"]
            isOneToOne: false
            referencedRelation: "fr_content"
            referencedColumns: ["id"]
          },
        ]
      }
      fr_content: {
        Row: {
          audio_url: string | null
          author: string | null
          category_1: string | null
          category_2: string | null
          category_3: string | null
          content: string | null
          content_multi: Json | null
          content_type: number
          created_at: string
          description: string | null
          description_dt: string | null
          description_en: string | null
          description_ge: string | null
          description_it: string | null
          description_jp: string | null
          description_pt: string | null
          description_sp: string | null
          id: number
          img_url: string | null
          is_free: boolean | null
          level: string | null
          title: string | null
        }
        Insert: {
          audio_url?: string | null
          author?: string | null
          category_1?: string | null
          category_2?: string | null
          category_3?: string | null
          content?: string | null
          content_multi?: Json | null
          content_type: number
          created_at?: string
          description?: string | null
          description_dt?: string | null
          description_en?: string | null
          description_ge?: string | null
          description_it?: string | null
          description_jp?: string | null
          description_pt?: string | null
          description_sp?: string | null
          id?: number
          img_url?: string | null
          is_free?: boolean | null
          level?: string | null
          title?: string | null
        }
        Update: {
          audio_url?: string | null
          author?: string | null
          category_1?: string | null
          category_2?: string | null
          category_3?: string | null
          content?: string | null
          content_multi?: Json | null
          content_type?: number
          created_at?: string
          description?: string | null
          description_dt?: string | null
          description_en?: string | null
          description_ge?: string | null
          description_it?: string | null
          description_jp?: string | null
          description_pt?: string | null
          description_sp?: string | null
          id?: number
          img_url?: string | null
          is_free?: boolean | null
          level?: string | null
          title?: string | null
        }
        Relationships: []
      }
      fr_flashcards: {
        Row: {
          audio_url: string | null
          chapter_id: number | null
          content_id: number | null
          created_at: string
          example: string | null
          example_translation: string | null
          finished_datetime: string | null
          function: string | null
          id: number
          status: string | null
          text: string | null
          text_translation: string | null
          user_id: string | null
          vocabulary_id: number | null
        }
        Insert: {
          audio_url?: string | null
          chapter_id?: number | null
          content_id?: number | null
          created_at?: string
          example?: string | null
          example_translation?: string | null
          finished_datetime?: string | null
          function?: string | null
          id?: number
          status?: string | null
          text?: string | null
          text_translation?: string | null
          user_id?: string | null
          vocabulary_id?: number | null
        }
        Update: {
          audio_url?: string | null
          chapter_id?: number | null
          content_id?: number | null
          created_at?: string
          example?: string | null
          example_translation?: string | null
          finished_datetime?: string | null
          function?: string | null
          id?: number
          status?: string | null
          text?: string | null
          text_translation?: string | null
          user_id?: string | null
          vocabulary_id?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "flashcards_fr_content_id_fkey"
            columns: ["content_id"]
            isOneToOne: false
            referencedRelation: "fr_content"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "flashcards_fr_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "flashcards_fr_vocabulary_id_fkey"
            columns: ["vocabulary_id"]
            isOneToOne: false
            referencedRelation: "fr_vocabulary"
            referencedColumns: ["id"]
          },
        ]
      }
      fr_progress: {
        Row: {
          chapter_id: number | null
          content_id: number | null
          content_type: number | null
          created_at: string
          finished_datetime: string | null
          id: number
          is_liked: boolean | null
          reading_status: string | null
          started_datetime: string | null
          user_id: string | null
        }
        Insert: {
          chapter_id?: number | null
          content_id?: number | null
          content_type?: number | null
          created_at?: string
          finished_datetime?: string | null
          id?: number
          is_liked?: boolean | null
          reading_status?: string | null
          started_datetime?: string | null
          user_id?: string | null
        }
        Update: {
          chapter_id?: number | null
          content_id?: number | null
          content_type?: number | null
          created_at?: string
          finished_datetime?: string | null
          id?: number
          is_liked?: boolean | null
          reading_status?: string | null
          started_datetime?: string | null
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "progress_fr_content_id_fkey"
            columns: ["content_id"]
            isOneToOne: false
            referencedRelation: "fr_content"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "progress_fr_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      fr_quiz_models: {
        Row: {
          answer_1: string | null
          answer_2: string | null
          answer_3: string | null
          answer_4: string | null
          chapter_id: number | null
          correct_answer: number
          created_at: string
          id: number
          question: string | null
          quiz_id: number | null
          reference_id: number | null
          tip: string | null
          type: number | null
        }
        Insert: {
          answer_1?: string | null
          answer_2?: string | null
          answer_3?: string | null
          answer_4?: string | null
          chapter_id?: number | null
          correct_answer: number
          created_at?: string
          id?: number
          question?: string | null
          quiz_id?: number | null
          reference_id?: number | null
          tip?: string | null
          type?: number | null
        }
        Update: {
          answer_1?: string | null
          answer_2?: string | null
          answer_3?: string | null
          answer_4?: string | null
          chapter_id?: number | null
          correct_answer?: number
          created_at?: string
          id?: number
          question?: string | null
          quiz_id?: number | null
          reference_id?: number | null
          tip?: string | null
          type?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "quizz_models_fr_chapter_id_fkey"
            columns: ["chapter_id"]
            isOneToOne: false
            referencedRelation: "fr_chapters"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "quizz_models_fr_reference_id_fkey"
            columns: ["reference_id"]
            isOneToOne: false
            referencedRelation: "fr_content"
            referencedColumns: ["id"]
          },
        ]
      }
      fr_quiz_results: {
        Row: {
          created_at: string
          filled_out: boolean | null
          finished_datetime: string | null
          id: number
          number_correct_answers: number | null
          quiz_id: number | null
          reference_id: number | null
          type: number | null
          user_id: string | null
        }
        Insert: {
          created_at?: string
          filled_out?: boolean | null
          finished_datetime?: string | null
          id?: number
          number_correct_answers?: number | null
          quiz_id?: number | null
          reference_id?: number | null
          type?: number | null
          user_id?: string | null
        }
        Update: {
          created_at?: string
          filled_out?: boolean | null
          finished_datetime?: string | null
          id?: number
          number_correct_answers?: number | null
          quiz_id?: number | null
          reference_id?: number | null
          type?: number | null
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "quiz_results_fr_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "quiz_results_quiz_id_fkey"
            columns: ["quiz_id"]
            isOneToOne: false
            referencedRelation: "fr_quiz_models"
            referencedColumns: ["id"]
          },
        ]
      }
      fr_vocabulary: {
        Row: {
          audio_url: string | null
          chapter_id: number | null
          content_type: number | null
          created_at: string
          example: string | null
          example_dt: string | null
          example_en: string | null
          example_ge: string | null
          example_it: string | null
          example_jp: string | null
          example_pt: string | null
          example_sp: string | null
          function: string | null
          id: number
          reference_id: number | null
          text: string | null
          text_dt: string | null
          text_en: string | null
          text_ge: string | null
          text_it: string | null
          text_jp: string | null
          text_pt: string | null
          text_sp: string | null
        }
        Insert: {
          audio_url?: string | null
          chapter_id?: number | null
          content_type?: number | null
          created_at?: string
          example?: string | null
          example_dt?: string | null
          example_en?: string | null
          example_ge?: string | null
          example_it?: string | null
          example_jp?: string | null
          example_pt?: string | null
          example_sp?: string | null
          function?: string | null
          id?: number
          reference_id?: number | null
          text?: string | null
          text_dt?: string | null
          text_en?: string | null
          text_ge?: string | null
          text_it?: string | null
          text_jp?: string | null
          text_pt?: string | null
          text_sp?: string | null
        }
        Update: {
          audio_url?: string | null
          chapter_id?: number | null
          content_type?: number | null
          created_at?: string
          example?: string | null
          example_dt?: string | null
          example_en?: string | null
          example_ge?: string | null
          example_it?: string | null
          example_jp?: string | null
          example_pt?: string | null
          example_sp?: string | null
          function?: string | null
          id?: number
          reference_id?: number | null
          text?: string | null
          text_dt?: string | null
          text_en?: string | null
          text_ge?: string | null
          text_it?: string | null
          text_jp?: string | null
          text_pt?: string | null
          text_sp?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "vocabulary_fr_chapter_id_fkey"
            columns: ["chapter_id"]
            isOneToOne: false
            referencedRelation: "fr_chapters"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "vocabulary_fr_reference_id_fkey1"
            columns: ["reference_id"]
            isOneToOne: false
            referencedRelation: "fr_content"
            referencedColumns: ["id"]
          },
        ]
      }
      profiles: {
        Row: {
          avatar_url: string | null
          created_at: string | null
          email: string | null
          full_name: string | null
          id: string
          is_premium: boolean | null
          last_new_content_notification_at: string | null
          native_language: string | null
          notification_tokens: string[]
          notification_tokens_updated_at: string | null
          notifications_enabled: boolean | null
          target_language: string | null
          theme_interest_1: string | null
          theme_interest_2: string | null
          theme_interest_3: string | null
          theme_interest_4: string | null
          theme_interest_5: string | null
          updated_at: string | null
          weekly_goal: number | null
        }
        Insert: {
          avatar_url?: string | null
          created_at?: string | null
          email?: string | null
          full_name?: string | null
          id: string
          is_premium?: boolean | null
          last_new_content_notification_at?: string | null
          native_language?: string | null
          notification_tokens?: string[]
          notification_tokens_updated_at?: string | null
          notifications_enabled?: boolean | null
          target_language?: string | null
          theme_interest_1?: string | null
          theme_interest_2?: string | null
          theme_interest_3?: string | null
          theme_interest_4?: string | null
          theme_interest_5?: string | null
          updated_at?: string | null
          weekly_goal?: number | null
        }
        Update: {
          avatar_url?: string | null
          created_at?: string | null
          email?: string | null
          full_name?: string | null
          id?: string
          is_premium?: boolean | null
          last_new_content_notification_at?: string | null
          native_language?: string | null
          notification_tokens?: string[]
          notification_tokens_updated_at?: string | null
          notifications_enabled?: boolean | null
          target_language?: string | null
          theme_interest_1?: string | null
          theme_interest_2?: string | null
          theme_interest_3?: string | null
          theme_interest_4?: string | null
          theme_interest_5?: string | null
          updated_at?: string | null
          weekly_goal?: number | null
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      count_new_content_for_language: {
        Args: {
          p_content_type: number
          p_since: string
          p_target_language: string
        }
        Returns: number
      }
      get_profiles_to_notify_new_content: {
        Args: { p_now?: string }
        Returns: {
          message_body: string
          message_title: string
          new_articles_count: number
          new_audiobooks_count: number
          notification_tokens: string[]
          profile_id: string
          target_language: string
        }[]
      }
      mark_profiles_new_content_notified: {
        Args: { p_notified_at?: string; p_profile_ids: string[] }
        Returns: number
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {},
  },
} as const
