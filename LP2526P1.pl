:- encoding(utf8).
% 117964 João Coelho
:- style_check(-discontiguous). % para nao se queixar descontinuidade da BD
:- set_prolog_flag(answer_write_options,[max_depth(0)]). % ver listas completas
:- ['codigoAuxiliar.pl']. % Ficheiro dado
:- ['bd_estudantes.pl']. % Ficheiro dado
:- ['listas_palavras.pl']. % Ficheiro dado


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%PARTE 1%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


/*
Predicado Auxiliar
tamanhoLista(Lista, Tamanho) é verdade se Tamanho for 
o nº de elementos da lista Lista
*/
tamanhoLista([], 0).
tamanhoLista([_|T],N) :- 
    tamanhoLista(T, N1), 
    N is N1+1.


/*
media(ListaValores, Media)
ListaValores é a lista com todos os valores observados
Media é a média dos valores dessa lista
*/
media([], 0) :- !. %para parar de procurar
media(ListaValores, Media) :-
    tamanhoLista(ListaValores, Tamanho), %nº elementos
    sum_list(ListaValores, Soma), %soma elementos
    Media_Nao_Arredondada is Soma / Tamanho,
    arredonda(Media_Nao_Arredondada, Media).


/*
mediaNotasPorIdade(IdadeMin, IdadeMax, Media)
IdadeMin é a idade mínima dos alunos a procurar
IdadeMax é a idade máxima (inclusivé) dos alunos a procurar
Media é a media de notas dos alunos entre essas idades
*/
mediaNotasPorIdade(IdadeMin, IdadeMax, Media) :-
    findall(Nota, (                 %Procura as notas 
        estudante(Id, Idade, _),    
        Idade > IdadeMin,
        Idade =< IdadeMax,
        exame(Id, Nota)             %que passem estas condicoes
    ), ListaNotas),                 
    media(ListaNotas, Media).       %Usa o predicado media/2 para a calcular


/*
freqPorGenero(Genero, MediaFreq)
MediaFreq é a média dos valores de frequência
às aulas dos alunos do género Genero
*/
freqPorGenero(Genero, MediaFreq) :-
    findall(Freq, (
        estudante(Id, _, Genero),   %variáveis singleton porque é irrelevante
        atividade(Id, _, _, Freq)
    ), ListaFreq), 
    media(ListaFreq, MediaFreq).


/*
alertaSaude(HorasSono, Exercicio, SaudeMental, ListaAlunos)
HorasSono, Exercicio e SaudeMental são os valores máximos de horas de sono, 
pontuação de exercicio fisico e saude mental dos alunos a procurar, 
respetivamente.
ListaAlunos é a lista ordenada de alunos com qualidade de alimentação
fraca, e com os valores abaixo dos máximos para as outras variáveis.
*/
alertaSaude(HorasSono, Exercicio, SaudeMental, ListaAlunos) :-
    findall(Id, (
        saude(Id, HorasSono_Id, fraca, Exercicio_Id, SaudeMental_Id),
        HorasSono_Id < HorasSono,   %As variáveis Id referem-se ao aluno Id
        Exercicio_Id < Exercicio,
        SaudeMental_Id < SaudeMental
    ), ListaAlunosDesord),
    sort(ListaAlunosDesord, ListaAlunos). %Lista ordenada


/*
probEcraNotasAltas(HorasEcra, Nota, Probabilidade)
HorasEcra é o valor de horas que o aluno a procurar passa em frente a um ecrã
Nota é o valor mínimo (não incluido) de nota do aluno a procurar
Probabilidade é a probabilidade condicionada do evento A 
(Nota do aluno acima de Nota) dado B (Aluno passa mais que Horas_Ecra)) 
de acordo com a fórmula.
*/
probEcraNotasAltas(HorasEcra, Nota, Probabilidade) :-
    findall(Id, (   %procura alunos que satisfazam A e B            
        exame(Id, Nota_Id),
        Nota_Id > Nota, %Evento A: Nota do aluno acima de Nota
        atividade(Id, _, HorasEcra_Id, _),
        HorasEcra_Id > HorasEcra %Evento B: Aluno passa mais que Horas_Ecra
    ), Lista_Ids),
    tamanhoLista(Lista_Ids, Numerador), %O Cardinal é o nº elementos lista
    findall(Id, (           
        atividade(Id, _, HorasEcra_Id, _),
        HorasEcra_Id > HorasEcra            %Evento B
    ), Lista_Ids2),
    tamanhoLista(Lista_Ids2, Denominador),
    Prob_Nao_Arredondada is Numerador / Denominador,  %Prob condicionada de A dado B
    arredonda(Prob_Nao_Arredondada, Probabilidade).


/*
Predicado Auxiliar
subtraiValor(Valor, Elemento, Resultado) é verdade se Resultado for 
a subtração de Valor ao Elemento
*/
subtraiValor(Valor, Elemento, Resultado) :-
    Resultado is Elemento - Valor.


/*
subtraiValorDeLista(Lista, Valor, Resultado)
Resultado é a lista que se obtém ao subtrair Valor a todos
os elementos de Lista.
*/
subtraiValorDeLista(Lista, Valor, Resultado) :-
    maplist(subtraiValor(Valor), Lista, Resultado).


/*
Predicado Auxiliar
quadrado(Elemento, Resultado) é verdade se Resultado for 
o valor que corresponde ao quadrado do Elemento
*/
quadrado(Elemento, Resultado) :-
    Resultado is Elemento * Elemento.


/*
somaQuadrados(Lista, Resultado)
Resultado é a soma do quadrado dos elementos da lista Lista.
*/
somaQuadrados(Lista, Resultado) :-
    maplist(quadrado, Lista, Lista_Quadrados), %Aplica o quadrado aos elem. da Lista
    sum_list(Lista_Quadrados, Resultado). %Soma os elem. da Lista


/*
produtoEscalar(Lista1, Lista2, Resultado)
Resultado é o número que se obtém após fazer o produto escalar
entre os elementos da lista Lista1 e da lista Lista2.
*/
produtoEscalar([], [], 0).
produtoEscalar([H1|T1], [H2|T2], Resultado) :-
    produtoEscalar(T1, T2, ResT),
    Resultado is (H1*H2) + ResT. %Multiplica as cabeças de cada lista e soma ao resto


/*
correlacao(Lista1, Lista2, Resultado)
Resultado é o valor da correlação dos valores de Lista1 e de Lista2
de acordo com a fórmula dada.
*/
correlacao(Lista1, Lista2, Resultado) :-
    media(Lista1, Media1),
    media(Lista2, Media2),
    %numerador
    subtraiValorDeLista(Lista1, Media1, ResT1),
    subtraiValorDeLista(Lista2, Media2, ResT2),
    produtoEscalar(ResT1, ResT2, Numerador),
    %denominador
    somaQuadrados(ResT1, QuadradoL1),
    somaQuadrados(ResT2, QuadradoL2),
    Denominador is sqrt(QuadradoL1 * QuadradoL2),
    %correlacao
    arredonda((Numerador/Denominador), Resultado).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%PARTE 2%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


/*
tamanho(Palavra, Tamanho)
Tamanho é o nº de caracateres da palavra Palavra
*/
tamanho(Palavra, Tamanho) :-
    string_chars(Palavra, L_Palavra), %Cada letra é um elem. de L_Palavra
    tamanhoLista(L_Palavra, Tamanho). %Nº Elem = Nº Letras


/*
verificaECalcula(Palavra1, Palavra2, CaracteresPalavra1, CaracteresPalavra2)
Predicado é verdade se palavras têm o mesmo tamanho.
CaracteresPalavra1 e CaracteresPalavra2 são as listas de caracteres
de Palavra1 e Palavra2 respetivamente.
*/
verificaECalcula(Palavra1, Palavra2, CaracteresPalavra1, CaracteresPalavra2) :-
    string_chars(Palavra1, CaracteresPalavra1),
    string_chars(Palavra2, CaracteresPalavra2),
    tamanhoLista(CaracteresPalavra1, Tamanho1),
    tamanhoLista(CaracteresPalavra2, Tamanho2),
    Tamanho1 =:= Tamanho2. %Só funciona se palavras tiverem o msm tamanho


/*
Predicado Auxiliar
PalavrasTamanhoN(ListaPalavras, Tamanho, N_Palavras) é verdade se N_Palavras
for o número de palavras de tamanho Tamanho na lista ListaPalavras.
*/
palavrasTamanhoN([], _, 0).
palavrasTamanhoN([H|T], N, Res) :-
    tamanho(H, Tamanho),
    Tamanho =:= N,  %Se a palavra tiver tamanho igual
    !, 
    palavrasTamanhoN(T, N, ResT), 
    Res is 1 + ResT. %Adiciona-se um ao Resultado
palavrasTamanhoN([_|T], N, Res) :- 
    palavrasTamanhoN(T, N, Res). %Para avançar na lista até tamanho igual


/*
quantasN(Id, N, Quantas)
Quantas é o número de palavras de tamanho N da lista identificada por Id
*/
quantasN(Id, N, Quantas) :-
    lista_palavras(Id, ListaPalavras), %Escolhe a lista pt ou mini
    palavrasTamanhoN(ListaPalavras, N, Quantas).


/*
Predicado Auxiliar
PalavrasComecadasC(ListaPalavras, Caracter, N_Palavras) é verdade se N_Palavras
for o número de palavras começadas por Caracter na lista ListaPalavras.
*/
palavrasComecadasC([], _, 0).
palavrasComecadasC([H|T], C, Res) :-
    string_chars(H, [SubH|_]), %Divide cada Palavra numa lista de letras
    SubH == C, %Se SubH, o 1 elemento dessa lista for C
    !,
    palavrasComecadasC(T, C, ResT),
    Res is 1 + ResT.
palavrasComecadasC([_|T], C, Res) :- 
    palavrasComecadasC(T, C, Res). %Para avançar na lista até C igual


/*
quantasC(Id, C, Quantas)
Quantas é o número de palavras começadas por C na lista identificada por Id
*/
quantasC(Id, C, Quantas) :-
    lista_palavras(Id, ListaPalavras),
    palavrasComecadasC(ListaPalavras, C, Quantas).


/*
apagaElemento(Elemento, Lista1, Lista2)
Lista 2 é a Lista 1 sem a primeira ocorrência do elemento Elemento
*/
apagaElemento(_, [], []) :- !.
apagaElemento(Elemento, [Elemento|T1], T1) :- !. %Encontra o elem., só apaga 1ª occ.
apagaElemento(Elemento, [H1|T1], [H1|ResT]) :- %Acumula os Restos menos o Elemento
    H1 \= Elemento, 
    apagaElemento(Elemento, T1, ResT). %Enquanto for diferente continuar


/*
Predicado Auxiliar
ParesAux(L_Caracteres, Acc, L_Posicoes) é verdade se L_Posicoes
for a lista com os pares (caracter, Acc), sendo caracter cada
elemento de L_Caracteres.
*/
paresAux([],_,[]).
paresAux([H|T], Acc, [(H, Acc) | ListaPosicoesT]) :-
    AccAtual is Acc + 1, %Atualizacao do indice
    paresAux(T, AccAtual, ListaPosicoesT).

/*
posicoesPalavra(Palavra, Posicoes)
Posicoes é a lista ordenada de pares (Palavra,Posicao)
*/
posicoesPalavra(Palavra, Posicoes) :-
    string_chars(Palavra, CaracteresPalavra), %Trabalhar c/ lsita de letras
    paresAux(CaracteresPalavra, 1, ListaPosicoes), %Chama o predicado Aux.
    sort(ListaPosicoes, Posicoes).


/*
Predicado Auxiliar
Pista1Aux(L_P1, L_P2, Pista) é verdade se Pista
for a lista nas condições do enunciado.
*/
pista1Aux([],[],[]).

%Letra na posição correta (2)
pista1Aux([H1|T1], [H2|T2], [2 | PistaT]) :- 
    H1 == H2, %Se os carc. estiverem na msm pos. preenche-se um 2
    !, %mais eficiente
    pista1Aux(T1, T2, PistaT).

%Letra não existe (0)
pista1Aux([_|T1], [_|T2], [0 | PistaT]) :- %Senao é 0
    pista1Aux(T1, T2, PistaT).


/*
pista1(Palavra1, Palavra2, Pista)
Pista tem
->2 na posição i, se Palavra1 e Palavra2 tiverem o mesmo carácter na posição i;
-> 0 na posição i, caso contrário.
*/
pista1(Palavra1, Palavra2, Pista) :-
    verificaECalcula(Palavra1, Palavra2, L1, L2),
    pista1Aux(L1, L2, Pista).


/*
Predicado Auxiliar
Pista2Aux(L_P1, L_P2, L_P1, Pista) é verdade se Pista
for a lista nas condições do enunciado.
*/
pista2Aux([], [], _, []).

%Letra na posição correta (2)
pista2Aux([H1|T1], [H2|T2], L1, [2 | PistaT]) :-
    H1 == H2, 
    !, 
    pista2Aux(T1, T2, L1, PistaT).

%Letra na posição errada (1)
pista2Aux([_|T1], [H2|T2], L1, [1 | PistaT]) :- %Preenche com 1 se H2 estiver em L1
    findall(H2, member(H2, L1), Res), %L1 é a lista COMPLETA de carct. da palavra 1
    Res \= [], %Só conta se existir      
    !,
    pista2Aux(T1, T2, L1, PistaT).

%Letra não existe (0)
pista2Aux([_|T1], [_|T2], L1, [0 | PistaT]) :- %Se nao preenche com 1 nem 2 entao é 0
    pista2Aux(T1, T2, L1, PistaT).


/*
pista2(Palavra1, Palavra2, Pista)
Pista tem
-> 2 na posição i, se Palavra1 e Palavra2 tiverem o mesmo carácter na posição i;
-> 1 na posição i, se o carácter i da palavra Palavra2 é diferente do da posição i da palavra
Palavra1, mas existe algures na palavra Palavra1;
-> 0 caso contrário.
*/
pista2(Palavra1, Palavra2, Pista) :-
    verificaECalcula(Palavra1, Palavra2, L1, L2),
    pista2Aux(L1, L2, L1, Pista).

/*
Predicado Auxiliar
sacoSemLetrasCorretas(L1, L2, Saco) é verdade se Saco
for a lista com as letras do palpite (L2) em posicoes erradas
ou que nao existem no mistério (L1), ou seja sem letras na posicao correta.
*/
sacoSemLetrasCorretas([],[],[]).
sacoSemLetrasCorretas([H1|T1], [H2|T2], Saco) :- 
    H1 == H2,
    !, 
    sacoSemLetrasCorretas(T1, T2, Saco). % Se caract. for igual não entra no saco
sacoSemLetrasCorretas([H1|T1], [_|T2], [H1|Saco]) :- 
    sacoSemLetrasCorretas(T1, T2, Saco).  % Se caract. for diferente, entra no saco


/*
Predicado Auxiliar
Pista3Aux(L_P1, L_P2, Saco, Pista) é verdade se Pista
for a lista nas condições do enunciado.
*/
pista3Aux([], [], _, []).

%Letra na posição correta (2)
pista3Aux([H1|T1], [H2|T2], Saco, [2 | PistaT]) :-
    H1 == H2,
    !,
    pista3Aux(T1, T2, Saco, PistaT).

%Letra na posição errada (1)
pista3Aux([_|T1], [H2|T2], Saco, [1 | PistaT]) :- 
    member(H2, Saco), %Verifica se a letra está no saco (conj. pos/letras erradas)
    !,
    apagaElemento(H2, Saco, Saco_Atual), %Apaga do saco p/ prox. recursao
    pista3Aux(T1, T2, Saco_Atual, PistaT).

%Letra não existe ou já considerada (0)
pista3Aux([_|T1], [_|T2], Saco, [0 | PistaT]) :-
    pista3Aux(T1, T2, Saco, PistaT).


/*
pista3(Palavra1, Palavra2, Pista)
Pista tem
-> 2 na posição i, se Palavra1 e Palavra2 tiverem o mesmo caracter na posição i;
-> 1 na posição i, se o caractere i da palavra Palavra2 é diferente do da posição i da
palavra Palavra1, mas existe algures na palavra Palavra1, mas não na posição correcta.
Por outro lado, se em Palavra2 existirem N caracteres C em posições erradas, os
primeiros M são marcados com 1 se existirem M caracteres C na palavra Palavra1, os
quais ainda não descobriste onde estão (Don’t panic: exemplos abaixo!);
-> 0 na posição i caso contrário.
*/
pista3(Palavra1, Palavra2, Pista) :-
    verificaECalcula(Palavra1, Palavra2, L1, L2),
    sacoSemLetrasCorretas(L1, L2, Saco),
    pista3Aux(L1, L2, Saco, Pista).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%PARTE 3%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


/*
Predicado Auxiliar
criaListaNPalavras(N, Palavra, Resultado) é verdade se Resultado é a lista com
N ocorrencias de Palavra.
*/
criaListaNPalavras(0, _, []).
criaListaNPalavras(N, Palavra, [Palavra|T]) :-
    N > 0,
    NT is N-1,
    criaListaNPalavras(NT, Palavra, T).


/*
Predicado Auxiliar
preparaListaComp(Lista, Comp, Res) é verdade se Res é a lista com tamanho Comp,
e, se a lista Lista tiver menos de Comp elementos, Res é a concatenação
da lista Lista com uma lista de elementos 'empty' até Res perfazer tamanho Comp.
*/
preparaListaComp(Lista, Comp, Res) :-
    tamanhoLista(Lista, Tamanho),
    Tamanho =:= Comp, %Não faz nada
    Res = Lista,
    !.
preparaListaComp(Lista, Comp, Res) :-
    tamanhoLista(Lista, Tamanho),
    Tamanho < Comp,
    Faltam is Comp-Tamanho, %Ao adicionar Faltam a Tamanho obtem-se Comp
    criaListaNPalavras(Faltam, empty, ListaEmptys),
    append(Lista, ListaEmptys, Res).


/*
Predicado Auxiliar
elementoEPosicao(N, Lista, Elemento) é verdade se Elemento é o elem.
da lista Lista na posicao N.
No entanto, como é iterativa,
elementoEPosicao(N, Lista, Elemento) é verdade se N é a posição
de Elemento na lista Lista.
*/
elementoEPosicao(1, [H|_], H).
elementoEPosicao(N, [_|T], X) :-
    elementoEPosicao(NT, T, X), % Procura na cauda primeiro
    N is NT + 1.  % Só agora faz a conta (Indice Atual = Indice Cauda + 1)


/*
Predicado Auxiliar
cumpre(restricao, ListaFilmes) é verdade se o filme na ListaFilmes
estiver numa posição compatível com a restricao.
*/

%terror
cumpre(terror(Filme), ListaFilmes) :-
    elementoEPosicao(Sessao, ListaFilmes, Filme),
    member(Sessao, [3,4,7]). %sessao de sabado as 20 e 21(3,4), dom as 20 (7)

%soPode
cumpre(soPode(Filme, SessaoPretendida), ListaFilmes) :-
    elementoEPosicao(Sessao, ListaFilmes, Filme),
	SessaoPretendida =:= Sessao.

%nunca
cumpre(nunca(Filme, SessaoProibida), ListaFilmes) :-
    elementoEPosicao(Sessao, ListaFilmes, Filme),
	SessaoProibida =\= Sessao.

%seguido
cumpre(seguido(Filme1, Filme2), ListaFilmes) :-
    elementoEPosicao(Sessao1, ListaFilmes, Filme1),
    elementoEPosicao(Sessao2, ListaFilmes, Filme2),
    Sessao2 =:= Sessao1 + 1,
    Sessao1 \= 4. %nao há filmes a seguir a sabado as 23

%naoSeguido
cumpre(naoSeguido(Filme1, Filme2), ListaFilmes) :-
    \+ cumpre(seguido(Filme1, Filme2), ListaFilmes),
    \+ cumpre(seguido(Filme2, Filme1), ListaFilmes).

%antes
cumpre(antes(Filme1, Filme2), ListaFilmes) :-
    elementoEPosicao(Sessao1, ListaFilmes, Filme1),
    elementoEPosicao(Sessao2, ListaFilmes, Filme2),
    Sessao1 < Sessao2.


/*
Predicado Auxiliar
verificaRestricoes(L_Restricoes, ListaFilmes) é verdade se cada elemento de
ListaFilmes cumpre cada restrição de L_Restricoes.
*/
verificaRestricoes([], _).
verificaRestricoes([Restricao | T], ListaFilmes) :-
    cumpre(Restricao, ListaFilmes),
    verificaRestricoes(T, ListaFilmes).


/*
Programacao é a lista ordenada sem elementos repetidos de listas
com as sessões de filmes de ListaFilmes e de acordo com as restrições
de ListaRestricoes
*/
maratonaFilmes(ListaFilmes, ListaRestricoes, Programacao) :-
    preparaListaComp(ListaFilmes, 7, ListaFilmesPrep), %Adiciona os emptys
    findall(Permutacao, (                         %Procurar solucoes
        permutation(ListaFilmesPrep, Permutacao), %Gerar solucoes
        verificaRestricoes(ListaRestricoes, Permutacao) %Testar solucoes
    ), ProgramacaoDesordenada),
    sort(ProgramacaoDesordenada, Programacao), %Ordenar Solucoes
    !.


