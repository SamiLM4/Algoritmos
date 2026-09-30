algoritmo "LogiFast"
// Disciplina: Algoritmo e Programação
// Descrição: Sistema de Gerenciamento de Entregas

tipo
   tEntrega = registro
      codigo: inteiro
      destinatario: caractere
      origem: inteiro
      destino: inteiro
      peso: real
      valorMercadoria: real
      prioridade: inteiro
      distancia: real
      status: inteiro
      custo: real
   fimregistro

var
   // Estruturas globais
   entregas: vetor[1..30] de tEntrega
   matrizDist: vetor[1..5, 1..5] de real
   percursoBase: vetor[1..10] de inteiro
   totalEntregas: inteiro

   // Constantes Simuladas
   MAX_ENTREGAS, MAX_REGIOES, URGENTE, PRIORITARIA, NORMAL: inteiro
   AGUARDANDO, EM_TRANSPORTE, ENTREGUE: inteiro
   VALOR_KM: real

   // Variáveis do Menu Principal
   opcaoMenu: inteiro
   qtdRegioes, iLoop: inteiro
   distTotalRecursiva: real

// ------------------------------------------------------------------
// PROCEDIMENTOS DE INICIALIZAÇÃO
// ------------------------------------------------------------------
procedimento inicializarConstantes()
inicio
   MAX_ENTREGAS <- 30
   MAX_REGIOES <- 5
   URGENTE <- 1
   PRIORITARIA <- 2
   NORMAL <- 3
   AGUARDANDO <- 1
   EM_TRANSPORTE <- 2
   ENTREGUE <- 3
   VALOR_KM <- 2.5
   totalEntregas <- 0
fimprocedimento

procedimento inicializarMatriz()
inicio
   // O VisuAlg exige um comando por linha. Não podemos usar ";"
   matrizDist[1,1] <- 0
   matrizDist[1,2] <- 12
   matrizDist[1,3] <- 18
   matrizDist[1,4] <- 16
   matrizDist[1,5] <- 0

   matrizDist[2,1] <- 12
   matrizDist[2,2] <- 0
   matrizDist[2,3] <- 15
   matrizDist[2,4] <- 10
   matrizDist[2,5] <- 14

   matrizDist[3,1] <- 18
   matrizDist[3,2] <- 15
   matrizDist[3,3] <- 0
   matrizDist[3,4] <- 18
   matrizDist[3,5] <- 22

   matrizDist[4,1] <- 16
   matrizDist[4,2] <- 10
   matrizDist[4,3] <- 18
   matrizDist[4,4] <- 0
   matrizDist[4,5] <- 20

   matrizDist[5,1] <- 0
   matrizDist[5,2] <- 14
   matrizDist[5,3] <- 22
   matrizDist[5,4] <- 20
   matrizDist[5,5] <- 0
fimprocedimento

// ------------------------------------------------------------------
// FUNÇÕES AUXILIARES E DE CÁLCULO
// ------------------------------------------------------------------
funcao calcularCusto(dist, peso: real; prio: inteiro): real
var
   custoBase, custoComPeso, acrescimoPrio, custoFinal: real
inicio
   custoBase <- dist * VALOR_KM

   // Regra de peso (Simplificada para evitar falhas do VisuAlg com "e")
   se (peso <= 5) entao
      custoComPeso <- custoBase
   senao
      se (peso <= 20) entao
         custoComPeso <- custoBase * 1.10
      senao
         se (peso <= 50) entao
            custoComPeso <- custoBase * 1.20
         senao
            custoComPeso <- custoBase * 1.35
         fimse
      fimse
   fimse

   // Regra de prioridade
   se (prio = NORMAL) entao
      acrescimoPrio <- 1.0
   senao
      se (prio = PRIORITARIA) entao
         acrescimoPrio <- 1.15
      senao
         se (prio = URGENTE) entao
            acrescimoPrio <- 1.30
         senao
            acrescimoPrio <- 1.0 // Padrão de segurança
         fimse
      fimse
   fimse

   // Resolve o bug de retornar expressões matemáticas diretamente
   custoFinal <- custoComPeso * acrescimoPrio

   retorne custoFinal
fimfuncao

funcao buscarEntrega(codPesquisa: inteiro): inteiro
var
   i, indiceEncontrado, codAtual: inteiro
inicio
   indiceEncontrado <- 0
   i <- 1

   enquanto (i <= totalEntregas) e (indiceEncontrado = 0) faca
      // DRIBLE DO BUG: Lê para uma variável simples antes de comparar no "se"
      codAtual <- entregas[i].codigo

      se (codAtual = codPesquisa) entao
         indiceEncontrado <- i
      fimse
      i <- i + 1
   fimenquanto

   retorne indiceEncontrado
fimfuncao
// ------------------------------------------------------------------
// FUNCIONALIDADES PRINCIPAIS
// ------------------------------------------------------------------
procedimento cadastrarEntrega()

var
   novoCodigo, origem, destino, prio, i: inteiro
   peso, valorMerc, distCalc: real
   destinatario: caractere
   codigoExiste: logico
inicio
   se (totalEntregas >= MAX_ENTREGAS) entao
      escreval("ERRO: Capacidade máxima de entregas atingida.")
   senao
      escreval("--- CADASTRAR ENTREGA ---")
      escreva("Código da Entrega: ")
leia(novoCodigo)

codigoExiste <- falso

se (totalEntregas > 0) entao
   para i de 1 ate totalEntregas faca
      se (entregas[i].codigo = novoCodigo) entao
         codigoExiste <- verdadeiro
      fimse
   fimpara
fimse

se (codigoExiste = verdadeiro) entao
   escreval("ERRO: Código já cadastrado!")
senao
   totalEntregas <- totalEntregas + 1
   entregas[totalEntregas].codigo <- novoCodigo

         // Drible do bug de memória do VisuAlg 3.0:
         // Lê para uma variável simples primeiro, depois passa para o registro!
         escreva("Destinatário: ")
         leia(destinatario)
         entregas[totalEntregas].destinatario <- destinatario

         repita
            escreva("Região Origem (1 a 5): ")
            leia(origem)
            escreva("Região Destino (1 a 5): ")
            leia(destino)
            se (origem = destino) ou (origem < 1) ou (origem > 5) ou (destino < 1) ou (destino > 5) entao
               escreval("ERRO: Origem e Destino devem ser válidos (1-5) e diferentes.")
            fimse
         ate (origem <> destino) e (origem >= 1) e (origem <= 5) e (destino >= 1) e (destino <= 5)

         entregas[totalEntregas].origem <- origem
         entregas[totalEntregas].destino <- destino

         repita
            escreva("Peso (kg): ")
            leia(peso)
            se (peso <= 0) entao
               escreval("ERRO: Peso deve ser maior que zero.")
            fimse
         ate (peso > 0)
         entregas[totalEntregas].peso <- peso

         repita
            escreva("Valor da Mercadoria (R$): ")
            leia(valorMerc)
            se (valorMerc < 0) entao
               escreval("ERRO: Valor não pode ser negativo.")
            fimse
         ate (valorMerc >= 0)
         entregas[totalEntregas].valorMercadoria <- valorMerc

         repita
            escreva("Prioridade (1-Urgente, 2-Prioritária, 3-Normal): ")
            leia(prio)
         ate (prio = 1) ou (prio = 2) ou (prio = 3)
         entregas[totalEntregas].prioridade <- prio

         entregas[totalEntregas].status <- AGUARDANDO

         distCalc <- matrizDist[origem, destino]
         entregas[totalEntregas].distancia <- distCalc
         entregas[totalEntregas].custo <- calcularCusto(distCalc, peso, prio)

         escreval("Entrega cadastrada com sucesso! Custo Estimado: R$ ", entregas[totalEntregas].custo:4:2)
      fimse
   fimse
fimprocedimento

procedimento alterarStatus(novoStatus: inteiro)
var
   cod, idx: inteiro
inicio
   escreva("Informe o código da entrega: ")
   leia(cod)
   idx <- buscarEntrega(cod)

   se (idx = 0) entao // Ajustado de -1 para 0
      escreval("Entrega não encontrada.")
   senao
      se (novoStatus = EM_TRANSPORTE) e (entregas[idx].status = AGUARDANDO) entao
         entregas[idx].status <- EM_TRANSPORTE
         escreval("Status alterado para EM TRANSPORTE.")
      senao
         se (novoStatus = ENTREGUE) e (entregas[idx].status = EM_TRANSPORTE) entao
            entregas[idx].status <- ENTREGUE
            escreval("Status alterado para ENTREGUE.")
         senao
            escreval("ERRO: Transição de status inválida!")
         fimse
      fimse
   fimse
fimprocedimento

procedimento ordenarFilaDespacho()
var
   i, j: inteiro
   aux: tEntrega
   trocou: logico
inicio
   // Método Bubble Sort com múltiplos critérios
   // A ordenação considera TODAS as entregas, independente do status.
   para i de 1 ate totalEntregas - 1 faca
      para j de 1 ate totalEntregas - i faca
         trocou <- falso

         // 1º Critério: Prioridade
         // Menor número = maior prioridade
         se (entregas[j].prioridade > entregas[j+1].prioridade) entao
            trocou <- verdadeiro
         senao
            se (entregas[j].prioridade = entregas[j+1].prioridade) entao

               // 2º Critério: Maior valor da mercadoria
               se (entregas[j].valorMercadoria < entregas[j+1].valorMercadoria) entao
                  trocou <- verdadeiro
               senao
                  se (entregas[j].valorMercadoria = entregas[j+1].valorMercadoria) entao

                     // 3º Critério: Maior peso
                     se (entregas[j].peso < entregas[j+1].peso) entao
                        trocou <- verdadeiro
                     senao
                        se (entregas[j].peso = entregas[j+1].peso) entao

                           // 4º Critério: Menor código
                           se (entregas[j].codigo > entregas[j+1].codigo) entao
                              trocou <- verdadeiro
                           fimse

                        fimse
                     fimse

                  fimse
               fimse

            fimse
         fimse

         // Realiza a troca
         se (trocou = verdadeiro) entao
            aux <- entregas[j]
            entregas[j] <- entregas[j+1]
            entregas[j+1] <- aux
         fimse

      fimpara
   fimpara

   // ----------------------------------------------------------
   // EXIBIÇÃO DA FILA COMPLETA
   // ----------------------------------------------------------

   escreval("")
   escreval("==============================================")
   escreval("          FILA DE DESPACHO")
   escreval("==============================================")

   se (totalEntregas = 0) entao
      escreval("Nenhuma entrega cadastrada.")
   senao

      para i de 1 ate totalEntregas faca

         escreval("")
         escreval("Posição: ", i)
         escreval("Código: ", entregas[i].codigo)
         escreval("Destinatário: ", entregas[i].destinatario)
         escreval("Origem: ", entregas[i].origem)
         escreval("Destino: ", entregas[i].destino)
         escreval("Peso: ", entregas[i].peso:4:2, " kg")
         escreval("Valor da mercadoria: R$ ", entregas[i].valorMercadoria:4:2)

         // Exibição da prioridade
         se (entregas[i].prioridade = URGENTE) entao
            escreval("Prioridade: URGENTE")
         senao
            se (entregas[i].prioridade = PRIORITARIA) entao
               escreval("Prioridade: PRIORITARIA")
            senao
               escreval("Prioridade: NORMAL")
            fimse
         fimse

         // Exibição do status
         se (entregas[i].status = AGUARDANDO) entao
            escreval("Status: AGUARDANDO")
         senao
            se (entregas[i].status = EM_TRANSPORTE) entao
               escreval("Status: EM TRANSPORTE")
            senao
               escreval("Status: ENTREGUE")
            fimse
         fimse

         escreval("Distância: ", entregas[i].distancia:4:2, " km")
         escreval("Custo: R$ ", entregas[i].custo:4:2)
         escreval("----------------------------------------------")

      fimpara

   fimse

   escreval("")
   escreval("Fila organizada e exibida com sucesso!")

fimprocedimento

// ------------------------------------------------------------------
// RECURSIVIDADE E MATRIZES
// ------------------------------------------------------------------
funcao calcularPercursoRecursivo(posicao, tam: inteiro): real
inicio
   // Caso-base: chegou no último ponto do percurso
   se (posicao >= tam) entao
      retorne 0
   senao
      // Passo recursivo: lendo o vetor percursoBase
      retorne matrizDist[percursoBase[posicao], percursoBase[posicao+1]] + calcularPercursoRecursivo(posicao + 1, tam)
   fimse
fimfuncao

procedimento exibirMatrizEAnalise()
var
   i, j: inteiro
   maior, menor, soma: real
   cont: inteiro
inicio
   maior <- 0
   menor <- 99999
   soma <- 0
   cont <- 0

   escreval("--- MATRIZ DE DISTÂNCIAS ---")
   para i de 1 ate MAX_REGIOES faca
      para j de 1 ate MAX_REGIOES faca
         escreva(matrizDist[i,j]:4)

         se (matrizDist[i,j] > maior) entao
            maior <- matrizDist[i,j]
         fimse

         // Desconsidera diagonal (i=j) ou distâncias 0
         se (i <> j) e (matrizDist[i,j] > 0) entao
            se (matrizDist[i,j] < menor) entao
               menor <- matrizDist[i,j]
            fimse
            soma <- soma + matrizDist[i,j]
            cont <- cont + 1
         fimse
      fimpara
      escreval("")
   fimpara

   escreval("Maior distância: ", maior, " km")
   escreval("Menor distância (ignora 0): ", menor, " km")
   se (cont > 0) entao
      escreval("Média das distâncias (ignora diagonal): ", (soma/cont):4:2, " km")
   fimse
fimprocedimento

// ------------------------------------------------------------------
// ALGORITMO PRINCIPAL
// ------------------------------------------------------------------
inicio
   inicializarConstantes()
   inicializarMatriz()

   repita
      escreval("")
      escreval("LOGIFAST - SISTEMA DE GERENCIAMENTO DE ENTREGAS")
      escreval("1. Cadastrar entrega")
      escreval("2. Ordenar Fila de Despacho")
      escreval("3. Iniciar transporte (Alterar Status)")
      escreval("4. Finalizar entrega (Alterar Status)")
      escreval("5. Exibir matriz de distâncias e análise")
      escreval("6. Calcular percurso recursivamente")
      escreval("10. Encerrar sistema")
      escreva("Escolha uma opção: ")
      leia(opcaoMenu)

      escolha opcaoMenu
         caso 1
            cadastrarEntrega()
         caso 2
            ordenarFilaDespacho()
         caso 3
            alterarStatus(EM_TRANSPORTE)
         caso 4
            alterarStatus(ENTREGUE)
         caso 5
            exibirMatrizEAnalise()
         caso 6
            // Teste da função recursiva implementado
            escreval("--- CÁLCULO DE PERCURSO RECURSIVO ---")
            escreva("Quantas regiões o percurso terá? (2 a 10): ")
            leia(qtdRegioes)

            se (qtdRegioes >= 2) e (qtdRegioes <= 10) entao
               para iLoop de 1 ate qtdRegioes faca
                  escreva("Digite a região ", iLoop, " (1 a 5): ")
                  leia(percursoBase[iLoop])
               fimpara

               // Chama a função recursiva começando na posição 1
               distTotalRecursiva <- calcularPercursoRecursivo(1, qtdRegioes)
               escreval("A distância total do percurso é: ", distTotalRecursiva, " km")
            senao
               escreval("ERRO: Quantidade inválida.")
            fimse
         caso 10
            escreval("Encerrando...")
         outrocaso
            escreval("Opção inválida!")
      fimescolha
   ate (opcaoMenu = 10)
fimalgoritmo