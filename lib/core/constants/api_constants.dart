class ApiConstants {
  ApiConstants._();

  // ── Active provider ───────────────────────────────────────────
  static const String activeBaseUrl = openRouterBaseUrl;
  static const String activeModel   = openRouterModel;

  // ── YOUR API KEY — paste it here ──────────────────────────────
  // This gets compiled into the app so it works on web and mobile.
  static const String apiKey = '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';

  // ── OpenRouter ────────────────────────────────────────────────
  static const String openRouterBaseUrl = 'https://openrouter.ai/api/v1/chat/completions';
  static const String openRouterModel   = 'nvidia/nemotron-3-super-120b-a12b:free';
  static const String appReferer        = 'https://flo-app.dev';
  static const String appTitle          = 'Flo Expense Tracker';

  // ── Groq (alternative — change activeBaseUrl/activeModel to use) ─
  static const String groqBaseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String groqModel   = 'llama-3.1-8b-instant';

  // ── Request settings ──────────────────────────────────────────
  static const int    maxTokens      = 512;
  static const double temperature    = 0.3;
  static const int    requestTimeout = 10;
}
