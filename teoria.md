# Teoria — Conceitos e Modelos de Aprendizado de Máquina

Explicações intuitivas dos principais conceitos e modelos estudados neste repositório.

---

## ALS — Alternating Least Squares

### O que é

O ALS é um algoritmo de **filtragem colaborativa** — um tipo de sistema de recomendação que aprende as preferências dos usuários a partir do seu histórico de comportamento, sem precisar saber nada sobre os produtos em si.

### A ideia central

Imagine uma planilha onde as linhas são clientes e as colunas são produtos. Cada célula contém quantas unidades aquele cliente comprou daquele produto. A maioria das células é zero — cada cliente compra apenas uma pequena fração de todos os produtos disponíveis.

```
         🍎  🥛  🍞  🧀  🥚
cliente1 [3,  0,  1,  0,  2]
cliente2 [0,  2,  0,  3,  0]
cliente3 [1,  0,  0,  0,  4]
```

O ALS tenta **preencher os zeros** — ou seja, estimar o quanto cada cliente gostaria de cada produto que ainda não comprou. Esses são os scores de recomendação.

### Como funciona — Fatoração de Matrizes

Para preencher os zeros, o ALS decompõe a matriz **R** em duas matrizes menores:

$$R \approx U \times V^T$$

- **U** — matriz de clientes `(n_clientes × k)`: cada cliente é representado por um vetor de `k` números
- **V** — matriz de produtos `(n_produtos × k)`: cada produto é representado por um vetor de `k` números
- **k** — número de **fatores latentes** (hiperparâmetro)

Os fatores latentes são abstratos — o modelo os descobre sozinho. Intuitivamente, poderiam representar características como "saudável", "indulgente" ou "econômico". Um cliente com valor alto no fator "saudável" receberá recomendações de produtos com valor alto nesse mesmo fator.

O score de um par (cliente, produto) é simplesmente o **produto escalar** entre seus vetores:

$$\text{score}(i, j) = U_i \cdot V_j$$

### O truque — Alternating

Encontrar U e V ao mesmo tempo é difícil — o problema é **não-convexo** (muitos mínimos locais). O ALS resolve isso de forma elegante:

- Se fixarmos **V**, resolver **U** vira uma regressão linear simples — com solução analítica exata
- Se fixarmos **U**, resolver **V** vira uma regressão linear simples — com solução analítica exata

Então alternamos:

```
passo 1: V fixo  → resolver U  (regressão linear)
passo 2: U fixo  → resolver V  (regressão linear)
passo 3: repetir até convergir
```

A cada iteração o erro diminui, até o modelo convergir.

### A fórmula

Em cada passo, a solução exata é:

$$U_i = (V^T V + \lambda I)^{-1} V^T R_i$$
$$V_j = (U^T U + \lambda I)^{-1} U^T R_j$$

O parâmetro **λ (lambda)** é a regularização — penaliza valores muito grandes em U e V, evitando que o modelo memorize os dados de treino (overfitting).

### Limitações

- **Cold Start Problem**: o ALS não consegue recomendar para clientes novos — sem histórico de compras, não há vetor U para esse cliente.
- **Escalabilidade**: a implementação ingênua (com loops) é lenta para matrizes muito grandes. Implementações industriais usam operações matriciais paralelizadas.

### Quando usar

- Quando você tem histórico de interações usuário-item (compras, cliques, visualizações)
- Quando os dados são **implícitos** (quantidade comprada, frequência) em vez de ratings explícitos (estrelas)
- Quando não há informações sobre os itens ou usuários além das interações

---

## Modelos de Difusão — DDPM

### O que é

Os modelos de difusão são modelos **generativos** — aprendem a criar novos dados (imagens, áudio, texto) que se parecem com os dados de treino. São a tecnologia por trás de ferramentas como DALL-E e Stable Diffusion.

### A ideia central

A inspiração vem da física: imagine uma gota de tinta caindo em um copo d'água. Aos poucos, a tinta se espalha até o líquido ficar completamente homogêneo. Esse processo é a **difusão**.

Os modelos de difusão fazem exatamente isso com imagens — só que ao contrário:

- **Forward process** (fácil): destruir uma imagem aos poucos, adicionando ruído até virar estática
- **Reverse process** (difícil): aprender a reconstruir a imagem a partir da estática

Se conseguirmos aprender o processo reverso, podemos partir de ruído puro e gerar uma imagem nova.

### O forward process — adicionando ruído

A cada passo `t`, adicionamos uma pequena quantidade de ruído gaussiano à imagem:

$$q(x_t | x_{t-1}) = \mathcal{N}(x_t;\; \sqrt{1 - \beta_t}\, x_{t-1},\; \beta_t I)$$

Após `T = 1000` passos, a imagem original virou ruído puro. O parâmetro `β_t` controla **quanto ruído** é adicionado em cada passo — é o **noise schedule**.

**O truque da reparametrização:** não precisamos aplicar o ruído passo a passo. Podemos ir diretamente de `x_0` para qualquer `x_t` em um único passo:

$$x_t = \sqrt{\bar{\alpha}_t}\, x_0 + \sqrt{1 - \bar{\alpha}_t}\, \varepsilon, \quad \varepsilon \sim \mathcal{N}(0, I)$$

onde $\bar{\alpha}_t = \prod_{s=1}^{t}(1 - \beta_s)$. Quando `t` é pequeno, `ᾱ_t ≈ 1` e a imagem está quase intacta. Quando `t = T`, `ᾱ_t ≈ 0` e a imagem é ruído puro.

### O noise schedule

O schedule define como `β_t` cresce ao longo dos `T` passos. O paper original usa uma escala **linear** — `β` cresce uniformemente de `0.0001` até `0.02`. Isso garante que o ruído seja adicionado de forma suave e progressiva.

### O reverse process — aprendendo a remover ruído

O modelo aprende a inverter o forward process. A cada passo, uma rede neural recebe a imagem ruidosa `x_t` e o timestep `t`, e **prediz o ruído** que foi adicionado:

$$\varepsilon_\theta(x_t, t) \approx \varepsilon$$

O timestep `t` é importante — a rede precisa saber "o quanto ruidosa" está a imagem para calibrar sua predição. Isso é feito via **sinusoidal time embedding**, a mesma ideia do Transformer.

### O treinamento

O objetivo de treino é surpreendentemente simples — minimizar o erro entre o ruído real e o ruído predito:

$$\mathcal{L} = \mathbb{E}_{t, x_0, \varepsilon} \left[ \| \varepsilon - \varepsilon_\theta(x_t, t) \|^2 \right]$$

A cada passo do treino:
1. Sorteia uma imagem `x_0` do dataset
2. Sorteia um timestep `t` aleatório
3. Sorteia ruído `ε ~ N(0, I)`
4. Corrompe a imagem: `x_t = √ᾱ_t · x_0 + √(1-ᾱ_t) · ε`
5. Prediz o ruído com a rede: `ε_θ(x_t, t)`
6. Calcula MSE e atualiza os pesos

### A arquitetura — U-Net

A rede neural usada é uma **U-Net** — uma arquitetura com formato de "U":

- **Encoder**: comprime a imagem progressivamente (28×28 → 14×14), capturando contexto global
- **Bottleneck**: processa a representação mais comprimida
- **Decoder**: reconstrói a imagem progressivamente (14×14 → 28×28)
- **Skip connections**: conectam encoder e decoder, preservando detalhes espaciais

O time embedding é injetado em cada bloco para que a rede saiba em qual timestep está operando.

### A geração — sampling

Para gerar uma imagem nova, partimos de ruído puro e aplicamos o processo reverso `T` vezes:

$$x_{t-1} = \frac{1}{\sqrt{\alpha_t}} \left( x_t - \frac{1 - \alpha_t}{\sqrt{1 - \bar{\alpha}_t}} \cdot \varepsilon_\theta(x_t, t) \right) + \sqrt{\beta_t} \cdot z$$

onde `z ~ N(0, I)` é ruído adicional (exceto no último passo). A cada passo a imagem fica um pouco mais nítida, até revelar a imagem final em `t = 0`.

### Limitações

- **Geração lenta**: gerar uma imagem requer `T = 1000` passos de rede neural — muito mais lento que GANs ou VAEs. Variantes como DDIM reduzem isso para ~50 passos.
- **Custo computacional**: treinar um modelo de difusão de qualidade requer GPUs potentes e dias de treinamento.

### Quando usar

- Geração de imagens de alta qualidade
- Quando diversidade e fidelidade importam mais que velocidade de geração
- Tarefas de inpainting (completar partes de imagens), super-resolução e tradução de imagens
