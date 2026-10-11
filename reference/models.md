# Token Plan Personal Edition — Supported Models & Endpoints

## Endpoints (Base URL)

| Purpose | Format | Used by |
|---|---|---|
| **Anthropic-compatible** | `https://token-plan.ap-southeast-1.maas.aliyuncs.com/apps/anthropic` | Claude Code |
| **OpenAI-compatible** | `https://token-plan.ap-southeast-1.maas.aliyuncs.com/compatible-mode/v1` | Codex |

> Beijing region: `token-plan.cn-beijing.maas.aliyuncs.com`
> ⚠️ Subscriptions **must** be purchased in the Beijing region, but the API is reachable from any regional endpoint.

### API paths

| Format | Full path |
|---|---|
| Anthropic Messages | `POST .../apps/anthropic/v1/messages` |
| OpenAI Chat | `POST .../compatible-mode/v1/chat/completions` |

### Authentication

| Format | Header |
|---|---|
| Anthropic | `x-api-key: <KEY>` or `Authorization: Bearer <KEY>` |
| OpenAI | `Authorization: Bearer <KEY>` |

---

## Available Models (Token Plan Personal Edition)

### Qwen
| Model ID | Capabilities | context |
|---|---|---|
| `auto` | reasoning, text (auto-selects the underlying model) | — |
| `qwen3.8-max` | reasoning, vision, text | 983616 |
| `qwen3.8-flash` | reasoning, vision, text | 983616 |
| `qwen3.7-max` | reasoning, text | 983616 |
| `qwen3.7-plus` | reasoning, vision, text | 983616 |
| `qwen3.6-flash` | reasoning, vision, text | 983616 |

### DeepSeek
| Model ID | Capabilities | context |
|---|---|---|
| `deepseek-v4.1-flash` | reasoning, vision, text | 1048576 |
| `deepseek-v4-pro` | reasoning, text | 1048576 |
| `deepseek-v4-pro-0813` | reasoning, text | 1048576 |
| `deepseek-v4-flash-0731` | reasoning, text | 1048576 |

### Zhipu (GLM)
| Model ID | Capabilities | context |
|---|---|---|
| `glm-5.3` | reasoning, text | 1048576 |
| `glm-5.2` | reasoning, text | 1048576 |

### Multimodal tools (image / audio / video)
| Model ID | Capability |
|---|---|
| `qwen-image-3.0-pro` | image generation |
| `qwen-audio-3.0-tts-plus` | text-to-speech |
| `qwen-audio-3.0-realtime-plus` | realtime voice chat |
| `qwen-audio-3.0-asr-flash` | speech recognition |
| `wan2.7-image` / `wan2.7-image-pro` | image generation |
| `happyhorse-1.1-i2v` / `-t2v` / `-r2v` | video generation |

---

## Built-in Model Tools (auto-triggered via the Responses API, billed as Credits)

| Tool | Name |
|---|---|
| Web search | `web_search` |
| Text-to-image search | `web_search_image` |
| Image-to-image search | `image_search` |
| Web scraping | `web_extractor` |
| Code interpreter | `code_interpreter` |

---

## Night Discount (22:00 – 08:00)

| Models | Discount |
|---|---|
| `qwen3.8-max`, `qwen3.8-flash` | **60% off** |
| `deepseek-v4-pro-0813`, `deepseek-v4-flash-0731`, `deepseek-v4.1-flash` | **50% off** |

---

## Subscription Tiers (Personal Edition)

| Tier | Monthly fee | Monthly quota |
|---|---|---|
| Lite | ¥39 (was ¥60) | 11,500 Credits |
| Essential | ¥79 (was ¥120) | 25,500 Credits |
| Standard | ¥139 (was ¥180) | 45,000 Credits |
| Pro | ¥499 (was ¥600) | 180,000 Credits |

> Add-on top-up pack: ¥100 / 20,000 Credits.
