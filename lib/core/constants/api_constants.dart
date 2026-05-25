class ApiConstants {
  ApiConstants._();

  // ── Active provider ───────────────────────────────────────────
  static const String activeBaseUrl = groqBaseUrl;
  static const String activeModel   = groqModel;

  // ── OpenRouter ────────────────────────────────────────────────
  static const String openRouterBaseUrl = 'https://openrouter.ai/api/v1/chat/completions';
  static const String openRouterModel   = 'nvidia/nemotron-3-super-120b-a12b:free';
  static const String appReferer        = 'https://flo-app.dev';
  static const String appTitle          = 'Flo Expense Tracker';

  // ── Groq (swap activeBaseUrl/activeModel to these to use) ─────
  static const String groqBaseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String groqModel   = 'llama-3.1-8b-instant';

  // ── Request settings ──────────────────────────────────────────
  static const int    maxTokens      = 512;
  static const double temperature    = 0.3;
  static const int    requestTimeout = 10;
}
