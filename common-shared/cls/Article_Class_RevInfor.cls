% =============================================================================
%  Article_Class_RevInfor.cls
%  Classe LaTeX personalizada para artigos da Revista InFor
% -----------------------------------------------------------------------------
%  O QUE É ESTE ARQUIVO?
%  Um arquivo .cls é uma "classe de documento" — o molde que define a aparência
%  e o comportamento de um documento LaTeX. É o que você escolhe na primeira
%  linha de um artigo, com \documentclass{...}.
%
%  Esta classe NÃO começa do zero: ela se apoia em outras classes, em camadas:
%
%        Article_Class_RevInfor   (este arquivo — ajustes da Revista InFor)
%                 |  herda de
%              abntex2             (normas da ABNT: NBR 6022, 10520, 6023, ...)
%                 |  herda de
%              memoir             (classe base, muito poderosa para livros/artigos)
%
%  Ou seja: aqui só definimos o que é ESPECÍFICO da revista; tudo o que é padrão
%  ABNT já vem pronto do abntex2, e os recursos de diagramação vêm do memoir.
%
%  COMO USAR (no início do main.tex de cada artigo):
%      \documentclass{../../common-shared/cls/Article_Class_RevInfor}
%
%  O caminho relativo ../../ existe porque os artigos ficam em
%  artigos/<nome-do-artigo>/, dois níveis abaixo da raiz do repositório.
%
%  Referência para quem quer aprender a escrever classes:
%      https://www.overleaf.com/learn/latex/Writing_your_own_class
% =============================================================================

% Exige uma versão razoavelmente moderna do LaTeX (LaTeX2e é o padrão atual).
\NeedsTeXFormat{LaTeX2e}

% Declara o nome da classe e uma data/descrição. Esse nome deve bater com o
% nome do arquivo (Article_Class_RevInfor.cls).
\ProvidesClass{Article_Class_RevInfor}[2023/10/27 Minimal ABNT class]


% =============================================================================
%  1. CARREGAMENTO DA CLASSE-BASE (abntex2)
% -----------------------------------------------------------------------------
%  \LoadClass é como um \documentclass usado DENTRO de uma classe: ele carrega
%  a classe abntex2 já com as opções abaixo. As opções entre colchetes são
%  repassadas em cascata para o abntex2, para o memoir e para o babel.
% =============================================================================
\LoadClass[
    %%%%%%%%%%%%%%%%% -- opções da classe memoir --
	article,			% formata como ARTIGO acadêmico (e não livro/tese)
	12pt,				% tamanho base da fonte do corpo do texto (12 pontos)
	oneside,			% impressão só na frente (use twoside para frente e verso)
	a4paper,			% tamanho do papel: A4
	%
    %%%%%%%%%%%%%%%%% -- opções da classe abntex2 --
	chapter=TITLE,		% títulos de capítulo em MAIÚSCULAS
	section=TITLE,		% títulos de seção em MAIÚSCULAS
	subsection=TITLE,	% títulos de subseção em MAIÚSCULAS
	subsubsection=TITLE % títulos de subsubseção em MAIÚSCULAS
    %
	%%%%%%%%%%%%%%%%% -- opções do pacote babel --
	english,			% idioma secundário (usado só para hifenização)
	brazil,				% idioma PRINCIPAL do documento (o último listado vence)
	sumario=tradicional %  estilo do sumário no padrão tradicional da ABNT
    %
	]{abntex2}


% =============================================================================
%  2. PACOTES FUNDAMENTAIS
% -----------------------------------------------------------------------------
%  \RequirePackage é o \usepackage usado dentro de uma classe. Cada pacote
%  adiciona recursos. Carregamos aqui, de uma vez, tudo o que os artigos da
%  revista costumam precisar — assim cada main.tex fica curto e limpo.
% =============================================================================

% Lista de símbolos/nomenclatura (ex.: lista de siglas e símbolos).
\RequirePackage{nomencl}

% Suporte a cores (permite \textcolor, colorir links, etc.).
\RequirePackage{color}

% Inclusão de figuras e imagens (fornece o comando \includegraphics).
\RequirePackage{graphicx}

% Colunas mais flexíveis em tabelas (tipos de coluna >{...}, m{}, etc.).
\RequirePackage{array}

% Cria hiperlinks clicáveis (sumário, citações, URLs) no PDF gerado.
\RequirePackage{hyperref}

% Ícone verde do ORCID + link (\orcidlink{0000-...}), desenhado com TikZ (não
% precisa de imagem externa). Usado no bloco de autoria (padrão Revista InFor).
\RequirePackage{orcidlink}

% Selos Creative Commons como glifos de fonte (\ccbyncsa, \ccLogo, ...). O
% rodapé da 1ª página usa a LOGOMARCA OFICIAL em imagem (ver seção do rodapé);
% estes glifos ficam disponíveis para uso no texto do artigo.
\RequirePackage{ccicons}

% Aparência dos links: texto colorido em vez de caixas. URLs (e-mail/ORCID) em
% azul, como no PDF oficial da revista; links internos e de citação em preto,
% para não poluir o corpo do texto.
\hypersetup{
    colorlinks=true,
    urlcolor=blue,
    linkcolor=black,
    citecolor=black
}

% Permite desenhar em coordenadas absolutas do papel (usado no banner de
% cabeçalho full-bleed, colado às bordas da folha). Fornece \AddToShipoutPictureBG
% e \AtPageUpperLeft.
\RequirePackage{eso-pic}

% Recorte de caixas em COORDENADAS FINAIS (\clipbox). Usado para aparar a base do
% banner. Preferido ao "trim" do \includegraphics porque, neste conjunto de
% pacotes (memoir + hyperref + ...), o analisador de trim/viewport do graphicx
% (\Gread@parse@vp) falha; o \clipbox não depende dele.
\RequirePackage{trimclip}


% Tabelas com traços horizontais profissionais (\toprule, \midrule, \bottomrule).
% Manual: https://linorg.usp.br/CTAN/macros/latex/contrib/booktabs/booktabs.pdf
\RequirePackage{booktabs}

% Controle fino de alinhamento/justificação (\Centering, \RaggedRight, ...).
% Manual: https://br.mirrors.cicku.me/ctan/macros/latex/contrib/ragged2e/ragged2e.pdf
\RequirePackage{ragged2e}

% Tabelas com LARGURA TOTAL definida: a coluna do tipo X estica para preencher.
% Manual: https://texdoc.org/serve/tabularx.pdf/0
\RequirePackage{tabularx}



% (Opcional) Espessura da linha do cabeçalho — descomente para ativar.
%\renewcommand{\headrulewidth}{0.4pt}


% =============================================================================
%  3. FONTES E CODIFICAÇÃO
% -----------------------------------------------------------------------------
%  Segundo a NBR 14724 (ABNT, 2011): fonte 12 para o texto e as referências;
%  fonte 10 (menor) para citações longas, notas de rodapé, paginação, legendas
%  de ilustrações e tabelas.
% =============================================================================

% Esta classe funciona com TRÊS motores de compilação: pdfLaTeX (padrão),
% XeLaTeX e LuaLaTeX. Cada um precisa de pacotes de fonte diferentes, então
% detectamos o motor com o pacote iftex e carregamos o que for adequado.
% O motor é escolhido no build, ex.:  make build ART=... ENGINE=xe
\RequirePackage{iftex}

% A Revista InFor usa a fonte Arial (sans-serif) em todo o texto. Reproduzimos
% isso com a fonte livre Arimo, clone metricamente compatível com a Arial.
\ifpdftex
    % ----- pdfLaTeX (motor padrão do projeto) -----
    % Permite digitar acentos direto no teclado (á, ç, ã) tratados como UTF-8.
    \RequirePackage[utf8]{inputenc}
    % Codificação T1: hifenização correta e acentos "de verdade" no PDF.
    \RequirePackage[T1]{fontenc}
    % No pdfLaTeX usamos o helvet (Nimbus Sans, clone de Helvetica) como fonte
    % principal -- próximo da Arial. Para a Arial "de verdade" (Arimo), compile
    % com XeLaTeX/LuaLaTeX (ENGINE=xe ou ENGINE=lua).
    \RequirePackage{helvet}
    \renewcommand{\familydefault}{\sfdefault}
\else
    % ----- XeLaTeX ou LuaLaTeX -----
    % Estes motores já são nativamente UTF-8: NÃO se usa inputenc/fontenc.
    % O fontspec permite usar fontes OpenType/TrueType.
    \RequirePackage{fontspec}
    % Arimo = clone livre e metricamente compatível com a Arial (vem no TeX
    % Live). É a reprodução mais fiel do padrão da Revista InFor.
    \setmainfont{Arimo}
    % Para a Arial original (se instalada na imagem/sistema), troque por:
    % \setmainfont{Arial}
\fi

% Indenta também o PRIMEIRO parágrafo de cada seção (padrão ABNT).
\RequirePackage{indentfirst}

% Melhora sutil da justificação e do espaçamento entre letras/palavras.
\RequirePackage{microtype}


% =============================================================================
%  4. LAYOUT DA PÁGINA
% =============================================================================

% ---------------------------------------------------------------------------
%  Página de título
% ---------------------------------------------------------------------------
% O abnTeX2 imprime, logo abaixo do título, um "título estrangeiro" (o título
% em outra língua) por meio do gancho \maketitlehookb, que usa \theforeigntitle.
% Esse comando só passa a existir se o artigo chamar \tituloestrangeiro{...}.
% Sem esse ajuste, um artigo que NÃO informa o título estrangeiro quebra com o
% erro "Undefined control sequence \theforeigntitle". Redefinimos o gancho para
% imprimir o título estrangeiro apenas quando ele tiver sido informado, tornando
% \tituloestrangeiro{} opcional.
\renewcommand{\maketitlehookb}{%
    \ifcsname theforeigntitle\endcsname
        \LARGE\center\textit{\theforeigntitle}%
    \fi
}

% ---------------------------------------------------------------------------
%  Fonte do TÍTULO (padrão Revista InFor)
% ---------------------------------------------------------------------------
% Na revista, o título vem em Arial (sans-serif, já é a fonte da classe), NEGRITO,
% CAIXA ALTA e corpo 12 — o MESMO tamanho do texto (e não grande como o padrão do
% memoir). Centralizado e com entrelinha 1,5 (herdada de \OnehalfSpacing).
% \pretitle/\posttitle são os ganchos do memoir que envolvem \@title.
% \MakeUppercase (recebe \@title como argumento único) força a caixa alta mesmo
% que o autor digite o título em caixa mista.
\pretitle{\begin{center}\normalfont\bfseries\normalsize\MakeUppercase}
\posttitle{\par\end{center}}

% ---------------------------------------------------------------------------
%  Bloco de AUTORIA (padrão Revista InFor)
% ---------------------------------------------------------------------------
% No PDF oficial o bloco do autor é ALINHADO À DIREITA (encostado na margem
% direita do texto, com a esquerda irregular), corpo 12, entrelinha SIMPLES
% (mais junto que o título 1,5), com:
%   - nome em NEGRITO;
%   - afiliação em ITÁLICO (quebra em mais de uma linha se for longa);
%   - e-mail em itálico, como link (azul);
%   - ORCID em itálico, como link, precedido do ícone verde \orcidlink.
%
% Ganchos \preauthor/\postauthor do memoir: trocamos a tabela padrão por um
% ambiente flushright (\raggedleft) com \SingleSpacing — a afiliação longa quebra
% sozinha, as linhas ficam juntas e todas encostam na margem direita. \normalsize
% = corpo 12.
\preauthor{\begin{flushright}\normalfont\normalsize\SingleSpacing}
\postauthor{\par\end{flushright}}

% ---------------------------------------------------------------------------
%  Dados do autor em partes: NOME, SOBRENOME e ANO
% ---------------------------------------------------------------------------
% O nome do autor aparece em DOIS formatos diferentes no artigo:
%   - no bloco de autoria, por extenso e na ordem direta:  "Jayson Magno da Silva";
%   - no cabeçalho corrido, no formato autor-data da ABNT: "SILVA, 2025".
% Para não digitar o mesmo dado duas vezes (e não deixar os dois formatos
% saírem do ar um do outro), guardamos as PARTES em três campos:
%
%     \nomeAutorRevInfor{Jayson Magno da}   % prenome(s) + partículas (de, da, dos)
%     \sobrenomeAutorRevInfor{Silva}        % sobrenome de chamada (vai em CAIXA ALTA)
%     \anoRevInfor{2025}                    % ano da publicação
%
% A partir deles a classe monta sozinha:
%   \nomeCompletoAutorRevInfor  -> "Jayson Magno da Silva" (para o bloco de autoria)
%   \autorDataRevInfor          -> "SILVA, 2025"           (para o cabeçalho corrido)
%
% Os três campos são OPCIONAIS: se não forem preenchidos, nada quebra — o
% cabeçalho corrido cai no texto configurado por \cabecalhoCorridoRevInfor{}
% (ou no placeholder "SOBRENOME, Ano"), como antes.
\newcommand{\@nomeAutorRevInfor}{}
\newcommand{\@sobrenomeAutorRevInfor}{}
\newcommand{\@anoRevInfor}{}
\newcommand{\nomeAutorRevInfor}[1]{\renewcommand{\@nomeAutorRevInfor}{#1}}
\newcommand{\sobrenomeAutorRevInfor}[1]{\renewcommand{\@sobrenomeAutorRevInfor}{#1}}
\newcommand{\anoRevInfor}[1]{\renewcommand{\@anoRevInfor}{#1}}

% "Nome Sobrenome" — ordem direta, como no bloco de autoria. O \space só entra
% se houver prenome, para não sobrar um espaço solto quando só o sobrenome for
% preenchido.
\newcommand{\nomeCompletoAutorRevInfor}{%
    \ifx\@nomeAutorRevInfor\@empty\else\@nomeAutorRevInfor\space\fi
    \@sobrenomeAutorRevInfor%
}

% "SOBRENOME, Ano" — formato autor-data da ABNT, usado no cabeçalho corrido.
\newcommand{\autorDataRevInfor}{%
    \MakeUppercase{\@sobrenomeAutorRevInfor}, \@anoRevInfor%
}

% \autorRevInfor{nome}{afiliação}{e-mail}{ORCID iD}
% Monta o bloco já formatado e o registra como autor (o \maketitle o imprime).
% O ORCID é só o identificador (ex.: 0000-0001-5858-2507); montamos a URL.
% Dica: passe \nomeCompletoAutorRevInfor no 1º argumento para reaproveitar o
% nome já informado em \nomeAutorRevInfor{} / \sobrenomeAutorRevInfor{}.
\newcommand{\autorRevInfor}[4]{%
    \autor{%
        {\bfseries #1}\\%
        {\itshape #2}\\%
        {\itshape\href{mailto:#3}{#3}}\\%
        \orcidlink{#4}~{\itshape\href{https://orcid.org/#4}{http://orcid.org/#4}}%
    }%
}

% A revista NÃO mostra data na abertura do artigo. Removemos a data do \maketitle
% fazendo o gancho "antes da data" engolir \@date (\@gobble), sem imprimir nada.
\predate{\@gobble}
\postdate{}

% ---------------------------------------------------------------------------
%  RESUMO / ABSTRACT (padrão Revista InFor)
% ---------------------------------------------------------------------------
% O ambiente resumo do abnTeX2 usa o "abstract" do memoir. Por padrão o memoir
% recua o resumo dos DOIS lados (\absleftindent/\absrightindent = \leftmargin),
% usa \small e herda a entrelinha 1,5. No PDF oficial o resumo é:
%   - LARGURA TOTAL do texto (sem recuo lateral),
%   - corpo 12 (\normalsize), justificado,
%   - entrelinha SIMPLES,
%   - SEM recuo de parágrafo (primeira linha alinhada às demais).
% Ajustamos os parâmetros do abstract do memoir para reproduzir isso.
\setlength{\absleftindent}{0pt}   % remove o recuo à esquerda
\setlength{\absrightindent}{0pt}  % remove o recuo à direita
\renewcommand{\abstracttextfont}{\normalfont\normalsize\SingleSpacing}
% \absparindent é fixado pelo memoir em \AtBeginDocument como \parindent (1,3 cm);
% zeramos DEPOIS, com nosso próprio \AtBeginDocument (executa após o do memoir).
\AtBeginDocument{\setlength{\absparindent}{0pt}}
% O ambiente resumo do abnTeX2 força o cabeçalho na fonte de capítulo (\chaptitlefont,
% grande). Redefinimos o ambiente para o cabeçalho "RESUMO" ficar em corpo 12 NEGRITO,
% CAIXA ALTA e centralizado — como no oficial —, preservando o bookmark do abnTeX2.
%
% O espaço entre "RESUMO" e o texto vinha grande porque, no memoir, o cabeçalho fica
% num center (trivlist) e o corpo num list, cada um somando \topsep/\parskip, ainda
% esticados pela entrelinha 1,5. Zeramos esses espaçamentos dentro do ambiente e
% deixamos \abstitleskip controlar o respiro (~uma linha), como no oficial.
\renewenvironment{resumo}[1][\resumoname]{%
    \PRIVATEbookmarkthis{#1}%
    \renewcommand{\abstractnamefont}{\normalfont\bfseries\normalsize}%
    \renewcommand{\abstractname}{\MakeUppercase{#1}}%
    % -24pt aproxima o espaço "RESUMO"->texto do oficial (~uma linha). O valor é
    % empírico (compensa o \parskip entre os ambientes e a entrelinha 1,5).
    \setlength{\abstitleskip}{-24pt}%
    \setlength{\topsep}{0pt}%
    \setlength{\partopsep}{0pt}%
    \begin{abstract}%
}{%
    \end{abstract}\PRIVATEclearpageifneeded%
}

% Palavras-chave / Keywords (padrão Revista InFor)
% ---------------------------------------------------------------------------
% No PDF oficial, as palavras-chave ocupam um PARÁGRAFO PRÓPRIO dentro do
% Resumo/Abstract, com o rótulo em negrito. Se o autor do artigo só digitar
% \textbf{Palavras-chave}: ... colado ao fim do último parágrafo do resumo
% (sem lembrar de deixar uma linha em branco antes), o texto acaba grudado no
% parágrafo anterior. O \par abaixo fecha o parágrafo em curso e garante a
% linha própria SEMPRE, independente do que o autor escreveu antes.
%
% Uso dentro do resumo em português:
%     \palavraschaveRevInfor{Termo um. Termo dois. Termo três.}
% Uso dentro do resumo em inglês (rótulo "Keywords" via argumento opcional):
%     \palavraschaveRevInfor[Keywords]{Term one. Term two. Term three.}
\newcommand{\palavraschaveRevInfor}[2][Palavras-chave]{%
    \par\noindent{\bfseries #1}: #2%
}

% Título em língua estrangeira (inglês), impresso ANTES do \begin{resumo}[Abstract].
% No oficial ele aparece entre as palavras-chave e o cabeçalho "ABSTRACT", no mesmo
% padrão do título principal: negrito, CAIXA ALTA, centralizado, entrelinha 1,5.
% Uso no corpo do texto (parte pré-textual):
%     \tituloestrangeiroRevInfor{Título traduzido do artigo}
% Os \vspace* dão o respiro parecido com o do PDF oficial (antes e depois do título).
\newcommand{\tituloestrangeiroRevInfor}[1]{%
    \vspace{\onelineskip}%
    {\centering\normalfont\bfseries\normalsize\MakeUppercase{#1}\par}%
    \vspace{\onelineskip}%
}

% ---------------------------------------------------------------------------
%  Banner de cabeçalho da revista (full-bleed / margem zero)
% ---------------------------------------------------------------------------
% A Revista InFor imprime, no topo da primeira página, uma faixa (banner) com
% a identidade visual da revista. Aqui o banner é colado às bordas SUPERIOR e
% LATERAIS do papel, SEM nenhuma margem (full-bleed), e o título do artigo passa
% a fluir logo abaixo dele.
%
% COMO USAR (no preâmbulo do main.tex, junto de \titulo{}, \autor{}, ...):
%     \cabecalhoRevInfor{cabecalho-img-revistainfor.png}
% O arquivo é procurado nos diretórios de \graphicspath. Se \cabecalhoRevInfor
% NÃO for chamado, nenhum banner é impresso (comportamento neutro).

% Guarda o nome do arquivo de imagem do banner (vazio = sem banner).
\newcommand{\@cabecalhoRevInforImg}{}
% Setter usado no preâmbulo para escolher a imagem do banner.
\newcommand{\cabecalhoRevInfor}[1]{\renewcommand{\@cabecalhoRevInforImg}{#1}}

% Por que recortar o banner? A arte oficial da Revista InFor é mais ACHATADA do
% que a nossa imagem. Em largura total a nossa renderiza ~4,6 cm de altura; a
% oficial tem ~3,7 cm. Como não dá para reduzir a altura mantendo a largura total
% sem distorcer, aparamos a BASE da imagem (some parte do globo do rodapé).
%
% O recorte é uma FRAÇÃO (19,4%) da altura do banner JÁ em largura total, então é
% independente do DPI embutido no PNG. Sobra 80,6% -> 0,806 x 4,6 cm ≈ 3,7 cm.
% Para ajustar a altura, mude apenas a fração 0.194 (maior = banner mais baixo).
%
% Papéis:
%   \@cabecalhoRevInforTrim    = quantos pt aparar da base (calculado)
%   \@cabecalhoRevInforInc     = comando que insere a imagem já recortada, largura total
%   \@cabecalhoRevInforReserve = espaço vertical a reservar p/ o título não sobrepor
% Todos são calculados UMA vez em \AtBeginDocument (contexto de topo, seguro),
% NÃO dentro de \maketitlehooka — ali medir a imagem e recortar falha (modo LR /
% expansão do gancho). \xdef/\global fazem os valores sobreviverem até o \shipout.
% acho que agora é só deixar o banner mais claro pra ficar totalmente igual ao artigo original
\newlength{\@cabecalhoRevInforTrim}
\newlength{\@cabecalhoRevInforReserve}
\newcommand{\@cabecalhoRevInforInc}{}

% O gancho \maketitlehooka roda DENTRO do \maketitle, em modo vertical, ANTES do
% título — lugar certo para (a) desenhar o banner no fundo da página e (b) reservar
% o espaço que empurra o título para baixo dele. Aqui NÃO medimos nem montamos nada:
% só usamos o que \AtBeginDocument já preparou. O desenho é adiado para o \shipout.
\renewcommand{\maketitlehooka}{%
    \ifx\@cabecalhoRevInforImg\empty\else
        % (1) Desenha a imagem no canto SUPERIOR-ESQUERDO do papel, em largura
        %     total, apenas nesta página (o '*' restringe à página corrente).
        %     \raisebox{-\height} baixa a imagem para que seu TOPO encoste na
        %     borda superior da folha (margem zero no topo); width=\paperwidth
        %     leva a imagem de uma borda lateral à outra (margem zero nas laterais).
        \AddToShipoutPictureBG*{%
            \AtPageUpperLeft{\raisebox{-\height}{\@cabecalhoRevInforInc}}%
        }%
        % (2) O desenho acima é camada de fundo e NÃO ocupa espaço no texto:
        %     reservamos aqui a altura do banner que passa da margem superior.
        \vspace*{\@cabecalhoRevInforReserve}%
    \fi
    % (3) Rodapé de licença Creative Commons — só na 1ª página (aqui roda o
    %     \maketitle). Definido logo abaixo.
    \@rodapeCCRevInforPrint
}

% ---------------------------------------------------------------------------
%  Rodapé de licença Creative Commons — 1ª página (padrão Revista InFor)
% ---------------------------------------------------------------------------
% No PDF oficial, o rodapé da PRIMEIRA página traz, junto à borda inferior da
% mancha e alinhado à esquerda: uma linha horizontal, a referência bibliográfica
% completa do artigo (\@rodapeRefRevInforText) e, abaixo dela, a logomarca
% Creative Commons (CC BY-NC-SA) seguida da frase "Artigo publicado em acesso
% aberto sob licença Creative Commons". Esse bloco aparece SÓ na 1ª página; nas
% demais páginas não há logomarca nem referência (só a numeração de página,
% cuidada à parte).
%
% A logomarca é a IMAGEM OFICIAL da Creative Commons (botão 80x15 "BY-NC-SA"),
% baixada do press kit da CC e guardada em
% common-shared/img/cc-by-nc-sa-80x15.png:
%   https://mirrors.creativecommons.org/presskit/buttons/80x15/png/by-nc-sa.png
% Ela substitui os glifos do pacote ccicons usados antes. O texto vem em corpo 9
% (\footnotesize), entrelinha simples.
%
% Para trocar a logomarca (outra licença, outro arquivo), use
% \logoCCRevInfor{nome-do-arquivo.png} no preâmbulo; passando vazio
% (\logoCCRevInfor{}) o rodapé sai só com a frase, sem imagem.
%
% Vem LIGADO por padrão (é elemento padrão da revista). Para trocar a frase, use
% \rodapeCCRevInfor{...} no preâmbulo; para DESATIVAR, passe vazio:
% \rodapeCCRevInfor{}.
\newcommand{\@rodapeCCRevInforText}{Artigo publicado em acesso aberto sob licença Creative Commons}
\newcommand{\rodapeCCRevInfor}[1]{\renewcommand{\@rodapeCCRevInforText}{#1}}

% Arquivo da logomarca (procurado no \graphicspath do artigo, que aponta para
% common-shared/img/) e sua altura impressa.
\newcommand{\@rodapeCCRevInforLogo}{cc-by-nc-sa-80x15.png}
\newcommand{\logoCCRevInfor}[1]{\renewcommand{\@rodapeCCRevInforLogo}{#1}}
% Linha horizontal acima do bloco. No PDF oficial da revista (temp/10-23-PB.pdf)
% ela NÃO tem a largura da mancha de texto: atravessa a folha quase de borda a
% borda (sobra ~0,2 cm de cada lado) e é AZUL-CLARA, fina — e não preta com a
% largura do texto, como estava aqui. Reproduzimos as três coisas:
%   - cor  : azul-claro amostrado do PDF oficial (#92CCDC);
%   - largura: \paperwidth menos 2x \@rodapeCCRevInforRegraMargem;
%   - espessura: 0,5pt.
\definecolor{revinforRodapeLinha}{rgb}{0.573,0.800,0.863}
\newlength{\@rodapeCCRevInforRegraMargem}
\setlength{\@rodapeCCRevInforRegraMargem}{0.2cm}
\newlength{\@rodapeCCRevInforRegraEsp}
\setlength{\@rodapeCCRevInforRegraEsp}{0.5pt}

% A régua propriamente dita. É um \makebox de LARGURA ZERO (não empurra nada) que
% recua para fora da mancha com um \hspace* negativo — por isso pode ser usada
% tanto dentro do bloco da 1ª página quanto no rodapé das demais páginas, que
% começam no mesmo ponto (a margem esquerda do texto).
\newcommand{\@regraRodapeRevInfor}{%
    \makebox[0pt][l]{%
        \hspace*{-\dimexpr1in+\oddsidemargin-\@rodapeCCRevInforRegraMargem\relax}%
        \textcolor{revinforRodapeLinha}{%
            \rule{\dimexpr\paperwidth-2\@rodapeCCRevInforRegraMargem\relax}%
                 {\@rodapeCCRevInforRegraEsp}}%
    }%
}

% Altura da régua acima da linha de base do rodapé, nas páginas 2 em diante
% (na 1ª página a régua vai dentro do bloco da licença, logo acima da referência).
\newlength{\@rodapeCCRevInforRegraAltura}
\setlength{\@rodapeCCRevInforRegraAltura}{14pt}

% Régua + número da página: é o rodapé das páginas a partir da 2ª. Como no PDF
% oficial da revista, a linha azul aparece em TODAS as páginas; só a logomarca
% CC, o texto da licença e a referência é que ficam restritos à 1ª página.
\newcommand{\@regraRodapeRevInforFoot}{%
    \raisebox{\@rodapeCCRevInforRegraAltura}{\@regraRodapeRevInfor}%
}

% Largura reservada à direita da referência para o número da página não
% colidir com o texto (ver \@rodapeCCRevInforPrint).
\newlength{\@rodapeCCRevInforNumGutter}
\setlength{\@rodapeCCRevInforNumGutter}{1.2cm}

\newlength{\@rodapeCCRevInforLogoH}
% 0,5cm de altura no botão 80x15 dá ~2,7cm de largura -- é o tamanho impresso no
% PDF oficial da revista (temp/10-23-PB.pdf), medido na p. 7.
\setlength{\@rodapeCCRevInforLogoH}{0.5cm}

% Referência bibliográfica completa do artigo (linha acima do selo CC), no
% padrão "SOBRENOME, Nome. Título: subtítulo. InFor, Inov. Form., Rev.
% NEaD-Unesp, São Paulo, v. X, n. X, p. XX-XX, ano. ISSN 2525-3476.".
%
% A AUTORIA, o TÍTULO e o ANO são montados a partir do que o artigo já informou
% no preâmbulo:
%     \sobrenomeAutorRevInfor{} + \nomeAutorRevInfor{} -> "SILVA, Jayson Magno da"
%     \titulo{}                                         -> o título do artigo
%     \anoRevInfor{}                                    -> o ano
% Volume, número e páginas só são conhecidos no fechamento da edição, então
% continuam como "X"/"XX-XX" — os editores preenchem na diagramação final.
% Cada pedaço não preenchido cai sozinho no placeholder antigo ("SOBRENOME,
% Nome", "Título: subtítulo", "ano"), sem quebrar nada.
%
% Para informar a referência definitiva de um artigo (ou para casos fora do
% padrão: dois autores, "et al."...), use \referenciaRevInfor{...} no preâmbulo
% do main.tex — ele sobrescreve tudo isto.

% "SILVA, Jayson Magno da" — formato autor da ABNT: sobrenome em caixa alta,
% prenomes e partículas depois da vírgula.
\newcommand{\autorReferenciaRevInfor}{%
    \ifx\@sobrenomeAutorRevInfor\@empty
        SOBRENOME, Nome%
    \else
        \MakeUppercase{\@sobrenomeAutorRevInfor}%
        \ifx\@nomeAutorRevInfor\@empty\else, \@nomeAutorRevInfor\fi
    \fi
}

% Título como digitado em \titulo{} (caixa mista, sem o \MakeUppercase que a
% abertura do artigo aplica).
\newcommand{\@tituloReferenciaRevInfor}{%
    \ifx\@title\@empty Título: subtítulo\else\@title\fi
}

% Ano da publicação; placeholder "ano" enquanto não houver \anoRevInfor{}.
\newcommand{\@anoReferenciaRevInfor}{%
    \ifx\@anoRevInfor\@empty ano\else\@anoRevInfor\fi
}

\newcommand{\@rodapeRefRevInforText}{\autorReferenciaRevInfor. \@tituloReferenciaRevInfor. \textit{InFor, Inov. Form., Rev. NEaD-Unesp}, São Paulo, v.~X, n.~X, p.~XX-XX, \@anoReferenciaRevInfor. ISSN 2525-3476. [a preencher].}
\newcommand{\referenciaRevInfor}[1]{\renewcommand{\@rodapeRefRevInforText}{#1}}

% Bloco "régua + referência + número da página" — o rodapé COMUM a TODAS as
% páginas do artigo. No PDF oficial da revista (temp/10-23-PB.pdf, pp. 8-32) a
% referência bibliográfica completa aparece no pé de todas as páginas, e não só
% na 1ª; o número da página fica à direita dela, CENTRADO verticalmente no bloco
% (na p. 11 do oficial o "11" alinha com a 2ª das 3 linhas da referência).
% Restritos à 1ª página ficam só a logomarca CC e a frase da licença.
%
% Os \parbox[c] põem os dois pedaços centrados na MESMA linha de base, de modo
% que o número acompanhe o bloco qualquer que seja o número de linhas da
% referência, em vez de cair sobre o texto ou sobre a régua.
\newcommand{\@blocoRefRodapeRevInfor}{%
    \@regraRodapeRevInfor\par
    \vspace{4pt}%
    \parbox[c]{\dimexpr\textwidth-\@rodapeCCRevInforNumGutter\relax}{%
        \@rodapeRefRevInforText}%
    \hfill
    \parbox[c]{\@rodapeCCRevInforNumGutter}{\raggedleft\thepage}\par
}

% Rodapé das páginas 2 em diante: o mesmo bloco acima, sem a logomarca CC.
% \parbox[t] faz a linha de base do rodapé (a \footskip abaixo da última linha
% do texto) coincidir com a RÉGUA; a referência desce a partir dela. Se o artigo
% desligar a referência (\referenciaRevInfor{}), sobra só a régua, como antes.
\renewcommand{\@regraRodapeRevInforFoot}{%
    \ifx\@rodapeRefRevInforText\empty
        \raisebox{\@rodapeCCRevInforRegraAltura}{\@regraRodapeRevInfor}%
    \else
        \parbox[t]{\textwidth}{%
            \normalfont\footnotesize\SingleSpacing
            \setlength{\parskip}{0pt}\setlength{\parindent}{0pt}%
            \@blocoRefRodapeRevInfor
        }%
    \fi
}

% Altura da linha de base do rodapé a partir da borda INFERIOR do papel.
% Aumente para subir o selo; diminua para descê-lo.
% \raisebox conta a partir da borda INFERIOR do papel: quanto MAIOR o valor,
% mais alto (mais perto do texto) o bloco fica. 1,5cm bastava quando só havia
% a linha do selo CC; agora o bloco também tem, ACIMA dela, a linha divisória
% e a referência bibliográfica (2 linhas) -- ou seja, o bloco ficou mais
% ALTO, então a base precisa descer (valor MENOR) para caber sem invadir a
% área de texto.
\newlength{\@rodapeCCRevInforRaise}
\setlength{\@rodapeCCRevInforRaise}{0.3cm}

% Desenha o rodapé como camada de FRENTE, só na página corrente (o '*' do
% \AddToShipoutPictureFG* restringe à 1ª página, onde o \maketitle roda).
% Alinha o selo à esquerda da mancha (1in + \oddsidemargin) e o fixa acima da
% borda inferior. Nada é impresso se o texto estiver vazio.
\newcommand{\@rodapeCCRevInforPrint}{%
    \ifx\@rodapeCCRevInforText\empty\else
        \AddToShipoutPictureFG*{%
            \AtPageLowerLeft{%
                \raisebox{\@rodapeCCRevInforRaise}{%
                    \hspace*{\dimexpr1in+\oddsidemargin\relax}%
                    \parbox[b]{\textwidth}{%
                        \normalfont\footnotesize\SingleSpacing
                        % \parskip/\parindent do corpo do texto (0,2cm / 1,3cm) não devem
                        % vazar para dentro deste bloco pequeno -- senão o rodapé fica alto
                        % demais e invade a área de texto da página. Zeramos localmente.
                        \setlength{\parskip}{0pt}\setlength{\parindent}{0pt}
                        \ifx\@rodapeRefRevInforText\empty\else
                            % Mesmo bloco régua+referência+número usado no rodapé
                            % das demais páginas, para que a 1ª página não fuja
                            % do padrão. O número é impresso AQUI DENTRO (e não
                            % pelo rodapé do estilo 'plain', desligado nesta
                            % página) para não sair um segundo número solto.
                            \@blocoRefRodapeRevInfor
                            \vspace{5pt}
                        \fi
                        \ifx\@rodapeCCRevInforLogo\empty\else
                            \raisebox{-0.15\height}{%
                                \includegraphics[height=\@rodapeCCRevInforLogoH]{\@rodapeCCRevInforLogo}}%
                            \hspace{1ex}%
                        \fi
                        \@rodapeCCRevInforText
                    }%
                }%
            }%
        }%
    \fi
}

% Preparação do banner (uma vez, em contexto de topo seguro). Precisa rodar ANTES
% do \maketitle abaixo — e roda, porque os ganchos \AtBeginDocument executam na
% ordem de declaração e este vem primeiro.
%   - mede a altura do banner em LARGURA TOTAL e apara 19,4% da base;
%   - monta \@cabecalhoRevInforInc = \clipbox{...}{\includegraphics[...]}, com os
%     valores de recorte JÁ expandidos em números literais (o \xdef evita que o
%     analisador de argumentos separe mal os campos e o torna global p/ o \shipout);
%   - calcula \@cabecalhoRevInforReserve = altura do banner recortado menos a
%     margem superior, ou seja, o quanto o título deve descer.
% \clipbox{esq base dir topo}{conteúdo}: apara essas medidas das bordas do
% conteúdo já composto (coordenadas finais) — aqui só a BASE (2º valor).
\AtBeginDocument{%
    \ifx\@cabecalhoRevInforImg\empty\else
        \settoheight{\@cabecalhoRevInforTrim}{%
            \includegraphics[width=\paperwidth]{\@cabecalhoRevInforImg}}%
        \setlength{\@cabecalhoRevInforTrim}{0.194\@cabecalhoRevInforTrim}%
        \xdef\@cabecalhoRevInforInc{%
            \noexpand\clipbox{0pt \the\@cabecalhoRevInforTrim\space 0pt 0pt}%
                {\noexpand\includegraphics[width=\noexpand\paperwidth]%
                {\@cabecalhoRevInforImg}}}%
        \settoheight{\@tempdima}{\@cabecalhoRevInforInc}%
        % Reserva = (altura do banner) - (offset do topo do texto) - AJUSTE.
        % O AJUSTE (54pt) desconta o espaço que o \maketitle do memoir já coloca
        % acima do título (\null+\topskip, \vskip 2em, o \topsep do center e a
        % subida das maiúsculas), deixando um respiro de ~8pt entre o banner e o
        % título — como na Revista InFor. Aumente/diminua o 54pt p/ menos/mais gap.
        \global\@cabecalhoRevInforReserve=%
            \dimexpr\@tempdima-1in-\topmargin-\headheight-\headsep-54pt\relax
    \fi
}

% Gera o título automaticamente no início do documento, sem precisar escrever
% \maketitle em cada artigo. O título/autor vêm de \titulo{}, \autor{}, etc.,
% definidos no main.tex.
\AtBeginDocument{
    \maketitle
}


% ---------------------------------------------------------------------------
%  Títulos de SEÇÃO (padrão Revista InFor)
% ---------------------------------------------------------------------------
% No PDF oficial da revista, os títulos de seção (ex.: "1 INTRODUÇÃO",
% "2 DA PESQUISA") são:
%   - Arial (sans-serif, já é a fonte da classe), NEGRITO;
%   - CORPO 12 — o MESMO tamanho do texto (e não grandes);
%   - CAIXA ALTA nas seções primárias, alinhados à ESQUERDA;
%   - com o número seguido de UM espaço simples até o título.
%
% Por padrão, o abnTeX2 imprime os títulos GRANDES: ele define
% \ABNTEXsectionfontsize=\Large, \ABNTEXsubsectionfontsize=\large, etc., e os
% aplica em \AtBeginDocument via \setsecheadstyle{...}. Como ele EXPANDE essas
% macros de tamanho naquele momento, basta redefini-las aqui (depois do
% \LoadClass e antes do \begin{document}) para que o corpo 12 negrito prevaleça.
% \ABNTEXsectionfont já é \sffamily; acrescentamos \bfseries e forçamos o corpo.
\renewcommand{\ABNTEXsectionfontsize}{\normalsize\bfseries}
\renewcommand{\ABNTEXsubsectionfontsize}{\normalsize\bfseries}
\renewcommand{\ABNTEXsubsubsectionfontsize}{\normalsize\bfseries}
\renewcommand{\ABNTEXsubsubsubsectionfontsize}{\normalsize\bfseries}

% Espaço entre o NÚMERO da seção e o TÍTULO. O memoir usa \quad (1 em) por
% padrão; a revista usa apenas um espaço simples ("1 INTRODUÇÃO"). O #1 é o
% nível (section, subsection, ...); \csname the#1\endcsname imprime o número.
\setsecnumformat{\csname the#1\endcsname\space}


% ---------------------------------------------------------------------------
%  Margens da página (comandos do memoir)
% ---------------------------------------------------------------------------
% \setlrmarginsandblock{esquerda}{direita}{*}  -> margens laterais
% \setulmarginsandblock{superior}{inferior}{*} -> margens superior/inferior
% O * pede ao memoir para calcular a dimensão restante automaticamente.
\setlrmarginsandblock{3cm}{3cm}{*}
\setulmarginsandblock{3cm}{3cm}{*}
% APLICA de fato as margens acima e recalcula o layout. Sempre necessário
% depois de mexer nas margens do memoir.
\checkandfixthelayout


% ---------------------------------------------------------------------------
%  Cabeçalhos e rodapés (padrão Revista InFor)
% ---------------------------------------------------------------------------
% No PDF oficial, A PARTIR DA 2ª PÁGINA (a 1ª é a página de rosto/resumo, sem
% cabeçalho corrido), o topo de cada página alterna entre:
%   - página ÍMPAR: "SOBRENOME, Ano" (autor-data, como uma citação);
%   - página PAR:   o título do artigo, em itálico.
% Ambos alinhados à esquerda, com uma linha horizontal separando do texto.
%
% O texto autor-data NÃO sai de \autor{} (que mistura afiliação/e-mail/ORCID
% no mesmo campo). Ele é montado a partir dos campos separados da seção de
% autoria — \sobrenomeAutorRevInfor{} e \anoRevInfor{} —, que produzem
% "SOBRENOME, Ano" via \autorDataRevInfor.
%
% Ordem de precedência do que é impresso nas páginas ímpares:
%   1. o texto passado a \cabecalhoCorridoRevInfor{...}, se usado (escape para
%      casos fora do padrão: dois autores, "et al.", ano ainda indefinido...);
%   2. \autorDataRevInfor, se sobrenome e ano estiverem preenchidos;
%   3. o placeholder "SOBRENOME, Ano", para lembrar que falta preencher.
% O título da página par já é conhecido (\titulo{...}) e não precisa configuração.
\newcommand{\@cabecalhoCorridoRevInforText}{%
    \ifx\@sobrenomeAutorRevInfor\@empty
        SOBRENOME, Ano%
    \else
        \ifx\@anoRevInfor\@empty
            SOBRENOME, Ano%
        \else
            \autorDataRevInfor%
        \fi
    \fi
}
\newcommand{\cabecalhoCorridoRevInfor}[1]{\renewcommand{\@cabecalhoCorridoRevInforText}{#1}}

% Define aqui um estilo de página chamado "meuestilo". Definir não é ativar:
% quem liga o cabeçalho corrido, a partir da 2ª página, é o próprio comando
% \textual (redefinido logo abaixo) — nenhum \pagestyle{} é necessário no
% main.tex de cada artigo.
\makepagestyle{meuestilo}

% Texto do cabeçalho, compartilhado entre par/ímpar: no modo 'oneside' (usado
% nesta classe) só o "odd" é de fato aplicado pelo LaTeX, então alternamos o
% conteúdo NÓS MESMOS verificando a paridade de \value{page} — funciona tanto
% em 'oneside' quanto em 'twoside', por isso definimos os dois.
% Folga entre a ÚLTIMA linha do cabeçalho e a régua horizontal. O memoir encosta
% o conteúdo do cabeçalho no pé da caixa de \headheight, o que deixava o texto
% colado na régua (~2pt). No PDF oficial da revista sobram ~9pt. O \raisebox com
% altura e profundidade ZERO sobe o bloco sem alterar o layout da página.
\newlength{\@cabecalhoCorridoRevInforFolga}
\setlength{\@cabecalhoCorridoRevInforFolga}{4pt}

% Rebaixamento da RÉGUA do cabeçalho em relação à linha de base do campo. Medido
% no PDF oficial (temp/10-23-PB.pdf, p. 11, a 288 dpi): a régua fica a 76,4pt do
% topo da folha e a última linha do cabeçalho termina em 58,5pt -- ou seja, ~18pt
% de respiro entre o texto e a régua, e não os ~5pt (0,3 linha) do memoir.
\newlength{\@cabecalhoCorridoRevInforRegraDesc}
\setlength{\@cabecalhoCorridoRevInforRegraDesc}{17pt}

% No PDF oficial o cabeçalho corrido é impresso em CORPO 10 com entrelinha
% SIMPLES (e não no corpo 12 / entrelinha 1,5 do texto), e o título NÃO vai em
% itálico: só o nome próprio "Plan Ceibal" é que sai em itálico, porque já vem
% assim de dentro de \titulo{}. Por isso aqui não há \itshape.
\newcommand{\@meuestiloCabecalhoTexto}{%
    % Régua horizontal do cabeçalho. No PDF oficial ela é a MESMA régua
    % azul-clara do rodapé (atravessa a folha quase de borda a borda), e não uma
    % linha preta da largura da mancha. \makeheadrule só sabe desenhar
    % {largura}{espessura}, então ele é desligado abaixo e a régua é impressa
    % aqui, numa caixa de largura ZERO (não empurra o texto do cabeçalho) e
    % rebaixada de \@cabecalhoCorridoRevInforRegraDesc (ver acima).
    \makebox[0pt][l]{%
        \raisebox{-\@cabecalhoCorridoRevInforRegraDesc}[0pt][0pt]{%
            \@regraRodapeRevInfor}}%
    \raisebox{\@cabecalhoCorridoRevInforFolga}[0pt][0pt]{%
        \parbox[b]{\textwidth}{%
            \normalfont\footnotesize\SingleSpacing
            \setlength{\parskip}{0pt}\setlength{\parindent}{0pt}%
            \raggedright
            \ifodd\value{page}%
                \@cabecalhoCorridoRevInforText%
            \else
                \@title%
            \fi
        }%
    }%
}
\makeoddhead{meuestilo}{\@meuestiloCabecalhoTexto}{}{}
\makeevenhead{meuestilo}{\@meuestiloCabecalhoTexto}{}{}

%% Régua do memoir desligada: quem a desenha agora é \@meuestiloCabecalhoTexto
%% (ver acima), para poder usar a régua azul-clara de largura total da revista.
\makeheadrule{meuestilo}{0pt}{0pt}

% O cabeçalho corrido nas páginas PARES imprime o título do artigo por
% extenso; títulos longos quebram em 2 linhas. O \headheight padrão (14,5pt)
% só cabe 1 linha, e o memoir avisa com "Overfull \vbox" nas páginas em que
% isso acontece. Aumentamos para caber 2 linhas com folga.
\setlength{\headheight}{36pt}

% Distância da última linha do TEXTO até a linha de base do rodapé. Com o bloco
% de referência bibliográfica no pé de todas as páginas, a régua passou a ser
% impressa NESSA linha de base (\parbox[t] em \@regraRodapeRevInforFoot) e as
% 3 linhas da referência descem a partir dela. Os 30pt padrão jogavam o bloco
% para fora da folha; 14pt põem a régua a 786pt do topo, a mesma altura medida
% no PDF oficial (temp/10-23-PB.pdf, p. 11).
\setlength{\footskip}{14pt}
\checkandfixthelayout

%% Rodapé: número de página alinhado à direita, igual ao restante do artigo
%% (mesmo critério usado no estilo 'plain', logo abaixo).
% O número da página vem DENTRO do bloco (à direita da referência), como no PDF
% oficial; por isso o campo direito do rodapé fica vazio -- senão sairia um
% segundo número solto sobre a régua.
\makeoddfoot{meuestilo}{\@regraRodapeRevInforFoot}{}{}
\makeevenfoot{meuestilo}{\@regraRodapeRevInforFoot}{}{}

% Ativação automática: o abnTeX2 (\textual, em modo 'article') liga
% \pagestyle{plain} ao entrar nos elementos textuais. Encadeamos "meuestilo"
% logo depois, sem precisar tocar o main.tex de cada artigo — o cabeçalho
% corrido passa a valer a partir da 1ª página textual (a 2ª página do PDF,
% já que a 1ª é a página de rosto/resumo).
\let\ABNTEXoldtextualRevInfor\textual
\renewcommand{\textual}{\ABNTEXoldtextualRevInfor\pagestyle{meuestilo}}





% ---------------------------------------------------------------------------
%  Numeração de página (padrão Revista InFor)
% ---------------------------------------------------------------------------
% No PDF oficial da revista, o número da página fica no RODAPÉ, alinhado à
% DIREITA (na margem externa do texto), em todas as páginas.
%
% No modo 'article' (usado nesta classe), o abnTeX2 aplica o estilo de página
% 'plain' aos elementos textuais (\pagestyle{plain} dentro de \textual). O
% 'plain' do memoir imprime o número CENTRALIZADO no rodapé
% (\makeoddfoot{plain}{}{\thepage}{}). Redefinimos o rodapé do 'plain' para
% colocar o número no terceiro campo (à direita), mantendo o cabeçalho vazio.
% Como as definições de estilo de página são globais e nada as reescreve depois,
% o \pagestyle{plain} do \textual passa a usar este rodapé.
%
% \makeoddfoot/\makeevenfoot recebem {esquerda}{centro}{direita}; deixamos os
% dois primeiros vazios e pomos \thepage à direita. (No modo 'oneside' usado
% aqui, só o "odd" é aplicado; definimos o "even" também por robustez.)
\makeoddfoot{plain}{\@regraRodapeRevInforFoot}{}{}
\makeevenfoot{plain}{\@regraRodapeRevInforFoot}{}{}

% EXCEÇÃO — 1ª página: nela o número já sai DENTRO do bloco de rodapé da licença
% (ao lado da referência, como no PDF oficial da revista). O \maketitle do memoir
% aplica a esta página o estilo 'title', que por padrão é um APELIDO de 'plain'
% (por isso não se pode redefinir 'title' diretamente: o memoir recusa). Criamos
% então um estilo próprio, sem nada no cabeçalho e no rodapé, e apontamos o
% apelido 'title' para ele — assim não sai um segundo número, solto sobre a
% linha horizontal do bloco.
\makepagestyle{revinforprimeirapagina}
\makeoddhead{revinforprimeirapagina}{}{}{}
\makeevenhead{revinforprimeirapagina}{}{}{}
\makeoddfoot{revinforprimeirapagina}{}{}{}
\makeevenfoot{revinforprimeirapagina}{}{}{}
\aliaspagestyle{title}{revinforprimeirapagina}


% ---------------------------------------------------------------------------
%  Parágrafos: recuo e espaçamentos
% ---------------------------------------------------------------------------

% Tamanho do recuo (indentação) da primeira linha de cada parágrafo.
\setlength{\parindent}{1.3cm}

% Espaço vertical adicional entre um parágrafo e outro.
\setlength{\parskip}{0.2cm}  % alternativa: \onelineskip

% Espaçamento entre linhas 1,5 -- exigido pelas normas da Revista InFor.
\OnehalfSpacing

% Remove o espaço extra (obsoleto) que o LaTeX antigo colocava após o ponto
% final de cada frase — padrão tipográfico correto para o português.
\frenchspacing


% ---------------------------------------------------------------------------
%  Pacote usado apenas no Modelo Canônico do abnTeX2
% ---------------------------------------------------------------------------
% Gera "texto de mentira" (\lipsum) para preencher exemplos e testar o layout.
\RequirePackage{lipsum}


% =============================================================================
%  5. CITAÇÕES E REFERÊNCIAS (padrão ABNT)
% =============================================================================

% backref: nas referências ao fim do documento, mostra em quais páginas cada
% obra foi citada. Opções: brazilian (textos em português) e hyperpageref
% (os números de página viram links).
\RequirePackage[brazilian,hyperpageref]{backref}

% abntex2cite com a opção 'alf' = sistema AUTOR-DATA (alfabético), conforme a
% ABNT NBR 6023/10520. Habilita \cite, \citeonline, \citeauthor, etc.
\RequirePackage[alf]{abntex2cite}


% ---------------------------------------------------------------------------
%  Personalização dos textos do backref
% ---------------------------------------------------------------------------
% Rótulo usado quando NÃO se usa a opção hyperpageref.
\renewcommand{\backrefpagesname}{Citado na(s) página(s):~}
% Texto que apareceria ANTES dos números de página (vazio aqui).
\renewcommand{\backref}{}

% Define, de forma condicional, a frase mostrada conforme o número de citações:
%   0  -> "Nenhuma citação no texto."
%   1  -> "Citado na página X."
%   >1 -> "Citado N vezes nas páginas ..."
% Os #1 (quantidade) e #2 (páginas) são preenchidos automaticamente.
\renewcommand*{\backrefalt}[4]{
	\ifcase #1 %
		Nenhuma citação no texto.%
	\or
		Citado na página #2.%
	\else
		Citado #1 vezes nas páginas #2.%
	\fi}%


% =============================================================================
%  6. METADADOS E APARÊNCIA DO PDF (exemplos opcionais)
% -----------------------------------------------------------------------------
%  As configurações abaixo estão DESATIVADAS (comentadas). Descomente e ajuste
%  se quiser gravar título/autor no PDF e escolher as cores dos links.
%  \@title e \@author referem-se ao que foi definido com \titulo{} e \autor{}.
%  Documentação: https://www.overleaf.com/learn/latex/Hyperlinks
% =============================================================================
%\hypersetup{
%     	%pagebackref=true,
%		pdftitle={\@title},
%		pdfauthor={\@author},
%    	pdfsubject={Modelo de artigo científico com abnTeX2},
%	    pdfcreator={LaTeX with abnTeX2},
%		pdfkeywords={abnt}{latex}{abntex}{abntex2}{artigo científico},
%		colorlinks=true,       		% true: links coloridos; false: links em caixa
%    	linkcolor=blue,          	% cor dos links internos
%    	citecolor=blue,        		% cor dos links de citação
%    	filecolor=magenta,      		% cor dos links de arquivos
%		urlcolor=blue,				% cor dos links de URL
%		bookmarksdepth=4			% profundidade dos marcadores no PDF
%}

% (Opcional) Redefinir o tom exato do azul usado nos links:
%\definecolor{blue}{RGB}{41,5,195}

% NOTA sobre \makeatletter / \makeatother: em arquivos .cls o caractere "@" já
% é tratado como letra, então esses comandos NÃO são necessários aqui (eles só
% fazem falta dentro de um .tex comum quando se usa macros internas com "@").
%\makeatletter
%\makeatother


% =============================================================================
%  7. GUIA RÁPIDO (referência para o autor do artigo)
% -----------------------------------------------------------------------------
%  Trechos de apoio retirados do Modelo Canônico do abnTeX2. Estão comentados
%  de propósito: servem como "cola" de como usar os recursos no main.tex.
% =============================================================================

% --- Recuo do ambiente citacao ---
% Em artigos (opção 'article'), pode ser útil ajustar o recuo das citações
% longas. No preâmbulo do main.tex, use:
%   \setlength{\ABNTEXcitacaorecuo}{1.8cm}
% (No modo 'twocolumn', o abntex2 já reduz o recuo de 4 cm para 1.8 cm.)

% --- Cabeçalhos e rodapés customizados ---
% O estilo "meuestilo" (seção 4) já é ativado automaticamente pela classe a
% partir da 1ª página textual — nenhum \pagestyle{} é necessário no main.tex.
% Ele imprime, em cada página a partir da 2ª do PDF, "SOBRENOME, Ano" (ímpares)
% ou o título do artigo em itálico (pares). O autor-data sai dos campos:
%     \nomeAutorRevInfor{Jayson Magno da}
%     \sobrenomeAutorRevInfor{Silva}
%     \anoRevInfor{2025}
% no preâmbulo do main.tex (o título já vem de \titulo{...}). Para um texto
% fora desse padrão, sobrescreva com \cabecalhoCorridoRevInfor{...}.
% Mais detalhes: seção 7.3 do manual do memoir.

% --- Mais exemplos ---
% Para figuras, fórmulas, citações e outros recursos, consulte o Modelo
% Canônico de Trabalhos Acadêmicos do abnTeX2 e o manual da classe abntex2.

% =============================================================================
%  FIM de Article_Class_RevInfor.cls
% =============================================================================
