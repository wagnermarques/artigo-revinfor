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

% Gera o título automaticamente no início do documento, sem precisar escrever
% \maketitle em cada artigo. O título/autor vêm de \titulo{}, \autor{}, etc.,
% definidos no main.tex.
\AtBeginDocument{
    \maketitle
}


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
