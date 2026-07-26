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

% Selos Creative Commons como glifos de fonte (\ccbyncsa, \ccLogo, ...), sem
% precisar de imagem externa. Usado no rodapé de licença da 1ª página.
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

% \autorRevInfor{nome}{afiliação}{e-mail}{ORCID iD}
% Monta o bloco já formatado e o registra como autor (o \maketitle o imprime).
% O ORCID é só o identificador (ex.: 0000-0001-5858-2507); montamos a URL.
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
% mancha e alinhado à esquerda, o selo Creative Commons (CC BY-NC-SA) seguido
% da frase "Artigo publicado em acesso aberto sob licença Creative Commons".
% O selo aparece SÓ na 1ª página.
%
% O selo é desenhado com o pacote ccicons (\ccbyncsa = glifos CC/BY/NC/SA), sem
% depender de imagem externa. O texto vem em corpo 9 (\footnotesize), entrelinha
% simples.
%
% Vem LIGADO por padrão (é elemento padrão da revista). Para trocar a frase, use
% \rodapeCCRevInfor{...} no preâmbulo; para DESATIVAR, passe vazio:
% \rodapeCCRevInfor{}.
\newcommand{\@rodapeCCRevInforText}{Artigo publicado em acesso aberto sob licença Creative Commons}
\newcommand{\rodapeCCRevInfor}[1]{\renewcommand{\@rodapeCCRevInforText}{#1}}

% Altura da linha de base do rodapé a partir da borda INFERIOR do papel.
% Aumente para subir o selo; diminua para descê-lo.
\newlength{\@rodapeCCRevInforRaise}
\setlength{\@rodapeCCRevInforRaise}{1.5cm}

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
                    {\normalfont\footnotesize
                     {\large\ccbyncsa}\hspace{1ex}\@rodapeCCRevInforText}%
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
%  Cabeçalhos e rodapés
% ---------------------------------------------------------------------------
% Aqui DEFINIMOS um estilo de página chamado "meuestilo". Atenção: definir não
% é ativar! Para usá-lo, escreva \pagestyle{meuestilo} no main.tex (após
% \begin{document}). Os textos abaixo são exemplos/placeholders — troque-os
% pelo conteúdo real do cabeçalho/rodapé do seu artigo.

%% Cria o novo estilo de cabeçalhos e rodapés
\makepagestyle{meuestilo}

%% Cabeçalho das páginas PARES (só aparece no modo twoside)
\makeevenhead{meuestilo}
    {Texto no topo, à esquerda (página par)} % à esquerda
    {Centro - \thepage} % ao centro (\thepage = número da página)
    {Texto à direita (página par)} % à direita

%% Cabeçalho das páginas ÍMPARES (ou de todas, no modo 'oneside' usado aqui)
\makeoddhead{meuestilo}
    {Texto no topo, à esquerda (página ímpar/oneside)} % à esquerda
    {Centro - \thepage} % ao centro (número da página)
    {Texto à direita (página ímpar/oneside)} % à direita

%% Linha horizontal separando o cabeçalho do texto
\makeheadrule{meuestilo}{\textwidth}{\normalrulethickness}

%% Rodapé das páginas PARES
\makeevenfoot{meuestilo}
    {Texto no rodapé, à esquerda (página par)} % à esquerda
    {Centro - \thepage} % ao centro (número da página)
    {Texto à direita (página par)} % à direita

%% Rodapé das páginas ÍMPARES (ou de todas, no modo 'oneside')
\makeoddfoot{meuestilo}
    {Texto no rodapé, à esquerda (página ímpar/oneside)} % à esquerda
    {Centro - \thepage} % ao centro (número da página)
    {Texto à direita (página ímpar/oneside)} % à direita





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
% O estilo "meuestilo" definido na seção 4 só é aplicado quando você escreve
% \pagestyle{meuestilo} logo após um comando de divisão do documento. Exemplo:
%   \begin{document}
%     \pretextual
%     \pagestyle{meuestilo}   % estilo na primeira página
%     \maketitle
%     ...
%     \textual
%     \pagestyle{meuestilo}   % estilo nas páginas de texto
%     \section{Nova seção}
%     ...
%   \end{document}
% A diferença entre páginas pares e ímpares só vale no modo 'twoside'. No modo
% 'oneside' (usado aqui), apenas o cabeçalho/rodapé "odd" é aplicado.
% Mais detalhes: seção 7.3 do manual do memoir.

% --- Mais exemplos ---
% Para figuras, fórmulas, citações e outros recursos, consulte o Modelo
% Canônico de Trabalhos Acadêmicos do abnTeX2 e o manual da classe abntex2.

% =============================================================================
%  FIM de Article_Class_RevInfor.cls
% =============================================================================
