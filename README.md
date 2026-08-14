# 🎵 Demonstração de Áudio na Godot Engine 4

Um projeto completo e interativo desenvolvido na **Godot Engine 4** para demonstrar conceitos práticos de áudio, desde reprodução não-posicional e áudio espacial (2D e 3D) até um sistema robusto de gerenciamento de áudio (**AudioManager Autoload**) com suporte a *crossfade* e persistência entre cenas.

---

## 📋 Índice

- [Visão Geral](#-visão-geral)
- [Demonstrações Inclusas](#-demonstrações-inclusas)
  - [1. Áudio Global e Controle Básico](#1-áudio-global-e-controle-básico)
  - [2. Áudio Espacial 2D](#2-áudio-espacial-2d)
  - [3. Áudio Espacial 3D e Doppler](#3-áudio-espacial-3d-e-doppler)
  - [4. AudioManager Singleton e Transições](#4-audiomanager-singleton-e-transições)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [AudioManager (Autoload) — Como Utilizar](#-audiomanager-autoload--como-utilizar)
- [Particularidades de Áudio na Godot 4](#-particularidades-de-áudio-na-godot-4)
- [Pré-requisitos e Como Executar](#-pré-requisitos-e-como-executar)
- [Licença](#-licença)

---

## 🌟 Visão Geral

Este projeto foi estruturado para servir tanto como **guia de estudos** quanto como **template base** para manipulação e arquitetura de áudio em jogos 2D e 3D utilizando a Godot Engine 4.

### Principais Destaques:
- 🎛️ **Controle de Parâmetros em Tempo Real**: Pitch scale, volume em decibéis (dB) e conversão linear.
- 📐 **Espacialização 2D e 3D**: Atenuação por distância, balanço estéreo (*panning*) e efeito Doppler.
- 🔄 **Looping Programático de WAV**: Configuração correta de pontos de loop em tempo de execução para `AudioStreamWAV`.
- 🔀 **Transições de Trilha Suaves**: Sistema com dois players de BGM alternados gerenciados por `Tween`.
- 🛡️ **Autoload Isolado em Cena (`.tscn`)**: Pré-configuração modular com nós dedicados para música e efeitos sonoros.

---

## 🎮 Demonstrações Inclusas

O projeto conta com um **Launcher Principal** (`main_launcher.tscn`) que permite navegar facilmente entre quatro módulos de teste:

```
+-------------------------------------------------------------+
|               DEMONSTRAÇÃO DE ÁUDIO - GODOT 4               |
|                                                             |
|  [ 1. Áudio Global / Básico ]   [ 2. Áudio Espacial 2D ]    |
|  [ 3. Áudio Espacial 3D ]       [ 4. AudioManager & Fades ] |
+-------------------------------------------------------------+
```

### 1. Áudio Global e Controle Básico
- **Cena**: `scenes/demo_1_global/demo_global.tscn`
- **Conceitos abordados**:
  - Uso do nó `AudioStreamPlayer` (áudio não-posicional, ideal para UI e BGM).
  - Ações de Play, Pause (`stream_paused`) e Stop.
  - Modulação dinâmica de **Pitch** (velocidade/tom) e **Volume** via sliders.
  - Habilitação dinâmica de **Loop** em arquivos WAV (`AudioStreamWAV.LOOP_FORWARD` e ajuste de `loop_end`).
  - Monitoramento de métricas em tempo real (posição de reprodução, pitch e ganho em dB).

### 2. Áudio Espacial 2D
- **Cena**: `scenes/demo_2_2d/demo_2d.tscn`
- **Conceitos abordados**:
  - Uso de `AudioStreamPlayer2D` e `AudioListener2D`.
  - Emissor sonoro interativo (arrastável com o mouse).
  - Visualização gráfica de atenuação (`max_distance`) e vetor de distância até o ouvinte desenhados via `_draw()`.
  - Cálculo e exibição em tempo real de distância e *stereo panning* relativo.
  - Modos de reprodução contínua em loop ou disparo único (*one-shot*).

### 3. Áudio Espacial 3D e Doppler
- **Cena**: `scenes/demo_3_3d/demo_3d.tscn`
- **Conceitos abordados**:
  - Uso de `AudioStreamPlayer3D` acoplado a um emissor esférico em órbita 3D procedural.
  - **Modelos de Atenuação 3D**:
    - *Inverse Distance* (Atenuação padrão realista)
    - *Logarithmic* (Atenuação logarítmica)
    - *Disabled* (Sem perda de volume por distância)
  - **Efeito Doppler**:
    - Suporte a rastreamento no *Idle Step* (`_process`) e no *Physics Step* (`_physics_process`).
  - Ajuste interativo do `unit_size` (escala de referência do som) e da velocidade orbital do emissor.

### 4. AudioManager Singleton e Transições
- **Cenas**: `scenes/demo_4_transition/scene_a.tscn` e `scene_b.tscn`
- **Conceitos abordados**:
  - Arquitetura de áudio global persistente entre trocas de cena (`change_scene_to_file`).
  - **Transição Seamless**: A música continua tocando sem reinício ao alternar entre as cenas.
  - **Transição Crossfade**: Esmaecimento cruzado automático entre trilhas diferentes via `Tween` (fade-out da trilha antiga e fade-in da nova).
  - Efeitos sonoros globais (*one-shot SFX*) com variação de tom aleatória (*pitch randomization*).
  - Controle de volume mestre direto no barramento do `AudioServer` ("Master").

---

## 📂 Estrutura do Projeto

```text
demonstracao-audio/
├── audio/                          # Amostras e trilhas de áudio (WAV, MP3, OGG)
│   ├── bgm_track_1.wav
│   ├── bgm_track_2.wav
│   ├── sfx_sample_2d.wav
│   └── sfx_sample_3d.wav
├── autoload/                       # Singletons globais
│   ├── audio_manager.gd            # Script com lógica de transições, BGM e SFX
│   └── audio_manager.tscn          # Cena com os nós de AudioStreamPlayer
├── scenes/                         # Cenas interativas
│   ├── demo_1_global/              # Demonstração 1: Controles básicos de áudio
│   ├── demo_2_2d/                  # Demonstração 2: Áudio posicional 2D
│   ├── demo_3_3d/                  # Demonstração 3: Áudio posicional 3D e Doppler
│   ├── demo_4_transition/          # Demonstração 4: Transições de cena com BGM
│   ├── main_launcher.gd            # Script do menu de seleção
│   └── main_launcher.tscn          # Menu de seleção principal
├── project.godot                   # Configurações do projeto da Godot Engine
├── LICENSE                         # Licença MIT
└── README.md                       # Documentação do projeto
```

---

## 🛠️ AudioManager (Autoload) — Como Utilizar

O `AudioManager` é registrado nas configurações do projeto (`project.godot`) como um nó global persistente. Ele pode ser acessado de qualquer script no projeto diretamente pelo nome `AudioManager`.

### Modos de Reprodução de BGM

```gdscript
# 1. Transição Suave (Crossfade) com duração customizada (em segundos):
AudioManager.play_bgm(trilha_audio, AudioManager.BGMMode.CROSSFADE, 1.5)

# 2. Reprodução Contínua (Seamless - não reinicia se já for a mesma trilha):
AudioManager.play_bgm(trilha_audio, AudioManager.BGMMode.SEAMLESS)

# 3. Parar a música com fade-out:
AudioManager.stop_bgm(1.0)
```

### Reprodução de Efeitos Sonoros Globais (SFX)

```gdscript
# Toca um SFX com variação de pitch para evitar repetição monótona:
AudioManager.play_sfx(meu_efeito_sonoro, randf_range(0.9, 1.2), 0.0)
```

### Controle de Barramentos de Áudio (AudioServer)

```gdscript
# Ajusta o volume do barramento Master usando escala linear de 0.0 a 1.0:
AudioManager.set_bus_volume("Master", 0.75)

# Obtém o valor linear atual:
var volume_linear: float = AudioManager.get_bus_volume("Master")
```

---

## 💡 Particularidades de Áudio na Godot 4

### 1. Looping de `AudioStreamWAV` em Tempo de Execução
Ao manipular arquivos `.wav` diretamente via GDScript, definir apenas `loop_mode = LOOP_FORWARD` pode não produzir repetição caso o `loop_end` seja igual a zero. É necessário garantir que o ponto final do loop corresponda à contagem total de amostras (*samples*):

```gdscript
var wav = stream as AudioStreamWAV
wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
if wav.loop_end <= wav.loop_begin:
    var total_samples = int(wav.get_length() * wav.mix_rate)
    if total_samples > 0:
        wav.loop_end = total_samples
```

### 2. Conversão de Volume: Linear vs. Decibéis (dB)
Sliders e interfaces de usuário operam intuitivamente em escala linear ($0.0$ a $1.0$ / $0\%$ a $100\%$), enquanto os nós de áudio da Godot operam em Decibéis ($-\infty\text{ dB}$ a $+6\text{ dB}$).
- Para converter: use as funções embutidas `linear_to_db()` e `db_to_linear()`.
- Lembre-se de limitar (*clamp*) o valor linear para evitar logaritmo de zero: `linear_to_db(clampf(val, 0.0001, 1.0))`.

---

## 🚀 Pré-requisitos e Como Executar

1. **Godot Engine 4.x** (versão 4.3 ou superior recomendada).
2. Clone ou baixe este repositório:
   ```bash
   git clone https://github.com/GuaraProductions/demonstracao-audio.git
   ```
3. Abra a **Godot Engine**, clique em **Importar** (*Import*) e selecione o arquivo `project.godot`.
4. Pressione **F5** (ou o botão de Play no canto superior direito) para iniciar a partir do menu principal (`main_launcher.tscn`).

---

## 📄 Licença

Este projeto está sob a licença [MIT](LICENSE). Consulte o arquivo `LICENSE` para mais informações.

Desenvolvido por **Guará Produções** (2026).
