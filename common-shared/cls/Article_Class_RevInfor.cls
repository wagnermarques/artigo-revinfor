%https://www.overleaf.com/learn/latex/Writing_your_own_class

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{Article_Class_RevInfor}[2023/10/27 Minimal ABNT class]


% Load basic document class
\LoadClass[            
    %%%%%%%%%%%%%%%%% -- opções da classe memoir --
	article,			% indica que é um artigo acadêmico
	12pt,				% tamanho da fonte [varFontSize]
	oneside,			% twoside configura a impressão para frente e verso.
	a4paper,			% tamanho do papel. 
	%
    %%%%%%%%%%%%%%%%% -- opções da classe abntex2 --
	chapter=TITLE,		% títulos de capítulos convertidos em letras maiúsculas
	section=TITLE,		% títulos de seções convertidos em letras maiúsculas
	subsection=TITLE,	% títulos de subseções convertidos em letras maiúsculas
	subsubsection=TITLE % títulos de subsubseções convertidos em letras maiúsculas
    %
	%%%%%%%%%%%%%%%%% -- opções do pacote babel --
	english,			% idioma adicional para hifenização
	brazil,				% o último idioma é o principal do documento
	sumario=tradicional %
    %
	]{abntex2}

% ---
% Pacotes fundamentais 
% ---

%%%%%%%%%%%%%%%%%%% 
%SUPORTE INICIAL
%%%%%%%%%%%%%%%%%%%


% Lista de simbolos
\RequirePackage{nomencl}


% Controle das cores
\RequirePackage{color}


% Inclusão de graficos e imagens
\RequirePackage{graphicx}		

\RequirePackage{array}
\RequirePackage{hyperref}


%tabelas
%https://linorg.usp.br/CTAN/macros/latex/contrib/booktabs/booktabs.pdf
\RequirePackage{booktabs}

%https://br.mirrors.cicku.me/ctan/macros/latex/contrib/ragged2e/ragged2e.pdf
\RequirePackage{ragged2e}

%tabularx package, which allows you to create a table with a specified total width. Here's an updated LaTeX 
%https://texdoc.org/serve/tabularx.pdf/0
\RequirePackage{tabularx}



%to ensure header is visible
%\renewcommand{\headrulewidth}{0.4pt}


%%%%%%%%%%%%%%%%%%% 
%      FONTES
%%%%%%%%%%%%%%%%%%%
%Segundo a NBR 14724 (ABNT, 2011), deve-se usar a fonte 12 para o texto e para as %referências. Para as citações longas, notas de fim de página (fonte 10), paginação, %legendas das ilustrações e tabelas, usar tamanho menor (1 ponto menor). 


% Codificacao do documento (conversão automática dos acentos)
\RequirePackage[utf8]{inputenc}

% Selecao de codigos de fonte.
\RequirePackage[T1]{fontenc}

% For more advanced font management
%Fatal Package fontspec Error: The fontspec package requires either XeTeX or
%\RequirePackage{fontspec}  

%\RequirePackage{courier}			% Usa a fonte Latin Modern
%\RequirePackage{uarial}
%Fatal Package fontspec Error: The fontspec package requires either XeTeX or
% If using XeLaTeX or LuaLaTeX
%\setmainfont{Arial}  

\RequirePackage{bookman}

% Indenta o primeiro parágrafo de cada seção.
\RequirePackage{indentfirst}		

% para melhorias de justificação
\RequirePackage{microtype} 			


%%%%%%%%%%%%%%%%%%% 
% LAYOUT DA PAGINA 
%%%%%%%%%%%%%%%%%%% 

% % % % % % % % % % % % 
%   página de titulo
% % % % % % % % % % % % 
\AtBeginDocument{
    \maketitle
}


% % % % % % % % % % % % 
% margem da pagina
%% % % % % % % % % % % % 
%\setlrmarginsandblock{MargemEsquerda em cm}{MargemEsquerda em cm}{*}
% no modelo tava 3cm 3cm
\setlrmarginsandblock{3cm}{3cm}{*}
\setulmarginsandblock{3cm}{3cm}{*}
\checkandfixthelayout
% ---

% % % % % % % % % % % % 
%   Cabecalho
% % % % % % % % % % % % 

%% Criar um novo estilo de cabeçalhos e rodapés
\makepagestyle{meuestilo}

%% Configuração dos cabeçalhos
% Definir cabeçalho para páginas pares (even pages)
\makeevenhead{meuestilo} % página par
    {Texto no topo, à esquerda (página par)} % Esquerda
    {Centro - \thepage} % Centro (número da página)
    {Texto à direita (página par)} % Direita

% Definir cabeçalho para páginas ímpares (odd pages) ou com opção 'oneside'
\makeoddhead{meuestilo} % página ímpar ou 'oneside'
    {Texto no topo, à esquerda (página ímpar/oneside)} % Esquerda
    {Centro - \thepage} % Centro (número da página)
    {Texto à direita (página ímpar/oneside)} % Direita

% Adicionar uma linha ao cabeçalho
\makeheadrule{meuestilo}{\textwidth}{\normalrulethickness}

%% Configuração dos rodapés
% Definir rodapé para páginas pares (even pages)
\makeevenfoot{meuestilo} % página par
    {Texto no rodapé, à esquerda (página par)} % Esquerda
    {Centro - \thepage} % Centro (número da página)
    {Texto à direita (página par)} % Direita

% Definir rodapé para páginas ímpares (odd pages) ou com opção 'oneside'
\makeoddfoot{meuestilo} % página ímpar ou 'oneside'
    {Texto no rodapé, à esquerda (página ímpar/oneside)} % Esquerda
    {Centro - \thepage} % Centro (número da página)
    {Texto à direita (página ímpar/oneside)} % Direita





% --- 
% PARAGRAFOS (Espaçamentos entre linhas e parágrafos )
% --- 

% O tamanho do parágrafo é dado por:
\setlength{\parindent}{1.3cm}

% Controle do espaçamento entre um parágrafo e outro:
\setlength{\parskip}{0.2cm}  % tente também \onelineskip

% Espaçamento simples
\SingleSpacing

% Retira espaço extra obsoleto entre as frases.
\frenchspacing 

		
% ---
% Pacotes adicionais, usados apenas no âmbito do Modelo Canônico do abnteX2
% ---
\RequirePackage{lipsum}				% para geração de dummy text
% ---
		
% ---
% Pacotes de citações
% ---
\RequirePackage[brazilian,hyperpageref]{backref}	 % Paginas com as citações na bibl
\RequirePackage[alf]{abntex2cite}	% Citações padrão ABNT
% ---


% ---
% Configurações do pacote backref
% Usado sem a opção hyperpageref de backref
\renewcommand{\backrefpagesname}{Citado na(s) página(s):~}
% Texto padrão antes do número das páginas
\renewcommand{\backref}{}

% Define os textos da citação
\renewcommand*{\backrefalt}[4]{
	\ifcase #1 %
		Nenhuma citação no texto.%
	\or
		Citado na página #2.%
	\else
		Citado #1 vezes nas páginas #2.%
	\fi}%
% ---

% informações do PDF (usar qdo preciso)
% https://www.overleaf.com/learn/latex/Hyperlinks
% configura links no pdf
%\hypersetup{
%     	%pagebackref=true,
%		pdftitle={\@title}, 
%		pdfauthor={\@author},
%    	pdfsubject={Modelo de artigo científico com abnTeX2},
%	    pdfcreator={LaTeX with abnTeX2},
%		pdfkeywords={abnt}{latex}{abntex}{abntex2}{atigo científico}, 
%		colorlinks=true,       		% false: boxed links; true: colored links
%    	linkcolor=blue,          	% color of internal links
%    	citecolor=blue,        		% color of links to bibliography
%    	filecolor=magenta,      		% color of file links
%		urlcolor=blue,
%		bookmarksdepth=4
%}

% End of Aticle_Class_RevInfor.cls{Aticle_Class_RevInfor}



% ---
% Configurações de aparência do PDF final

% alterando o aspecto da cor azul
%\definecolor{blue}{RGB}{41,5,195}

% testar depois pra ver se he realmente necessario
% constrola o uso do caractere "@" 
% pois he um caractere especifico pro latex para macros
% he usado em conjunto com \makeatother
%\makeatletter

%\makeatother
% --- 


% ----------------------------------------------------------
% Seção de explicações
% ----------------------------------------------------------

%\subsection{Recuo do ambiente \texttt{citacao}}

%Na produção de artigos (opção \texttt{article}), pode ser útil alterar o recuo
%do ambiente \texttt{citacao}. Nesse caso, utilize o comando:

%\begin{verbatim}
%   \setlength{\ABNTEXcitacaorecuo}{1.8cm}
%\end{verbatim}

%Quando um documento é produzido com a opção \texttt{twocolumn}, a classe
%\textsf{abntex2} automaticamente altera o recuo padrão de 4 cm, definido pela
%ABNT NBR 10520:2002 seção 5.3, para 1.8 cm.

%\section{Cabeçalhos e rodapés customizados}

%Diferentes estilos de cabeçalhos e rodapés podem ser criados usando os
%recursos padrões do \textsf{memoir}.

%Um estilo próprio de cabeçalhos e rodapés pode ser diferente para páginas pares
%e ímpares. Observe que a diferenciação entre páginas pares e ímpares só é
%utilizada se a opção \texttt{twoside} da classe \textsf{abntex2} for utilizado.
%Caso contrário, apenas o cabeçalho padrão da página par (\emph{even}) é usado.

%Veja o exemplo abaixo cria um estilo chamado \texttt{meuestilo}. O código deve
%ser inserido no preâmbulo do documento.


%Para usar o estilo criado, use o comando abaixo imediatamente após um dos
%comandos de divisão do documento. Por exemplo:

%\begin{verbatim}
%  \begin{document}
     %%usar o estilo criado na primeira página do artigo:
%     \pretextual
%     \pagestyle{meuestilo}
%     
%     \maketitle
%     ...
%     
     %%usar o estilo criado nas páginas textuais
%     \textual
%     \pagestyle{meuestilo}
%     
%     \chapter{Novo capítulo}
%     ...
%   \end{document}  
%\end{verbatim}
   
%Outras informações sobre cabeçalhos e rodapés estão disponíveis na seção 7.3 do
%manual do \textsf{memoir} \cite{memoir}.

%\section{Mais exemplos no Modelo Canônico de Trabalhos Acadêmicos}

%Este modelo de artigo é limitado em número de exemplos de comandos, pois são
%apresentados exclusivamente comandos diretamente relacionados com a produção de
%artigos.

%Para exemplos adicionais de \abnTeX\ e \LaTeX, como inclusão de figuras,
%%fórmulas matemáticas, citações, e outros, consulte o documento
%\citeonline{abntex2modelo}.

%\section{Consulte o manual da classe \textsf{abntex2}}

%Consulte o manual da classe \textsf{abntex2} \cite{abntex2classe} para uma
%referência completa das macros e ambientes disponíveis.

% ---
% Finaliza a parte no bookmark do PDF, para que se inicie o bookmark na raiz
% ---
%\bookmarksetup{startatroot}% 
% ---

% ---
% Conclusão
% ---
%\section*{Considerações finais}
%\addcontentsline{toc}{section}{Considerações finais}

%\lipsum[1]

%\begin{citacao}
%\lipsum[2]
%\end{citacao}

%\lipsum[3]

% % % % % % % % % % % % % % % % % % % % % % % % 
%           ELEMENTOS PÓS-TEXTUAIS
% % % % % % % % % % % % % % % % % % % % % % % % 
%\postextual

% ----------------------------------------------------------
% Referências bibliográficas
% ----------------------------------------------------------
%\bibliography{abntex2-modelo-references}

%\end{document}

