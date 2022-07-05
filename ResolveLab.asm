.data
     arquivo: .asciiz "maze-1-1.pgm"                       #Arquivo que sera lido o labirinto
     novoArquivo: .asciiz "SolucaoLab.pgm"                 #Arquivo onde sera escrito a resolu��o do labirinto
     buffer: .space 128000                                 #Quantidade usada de bits (com base nos 5 exemplos)
     
     zero: .asciiz "0"                                     #C�digo em ASCII para o n�mero 0 (preto)
     dois: .asciiz "2"                                     #C�digo em ASCII para o n�mero 2 (o 1� numero de 255, que � branco)
     pula: .asciiz "\n"                                    #C�digo em ASCII para nova linha (pula a linha para a proxima)
     retorna: .asciiz "\r"                                 #C�digo em ASCII para retorno 
     espaco: .asciiz " "                                   #C�digo em ASCII para espa�o
     
.text
     abrirArquivo:
          li $v0, 13                                       #Comando para abrir o arquivo, no caso o "maze.pgm", atribuindo 13 para $v0
          la $a0, arquivo                                  #Atribui para $a0 o "valor" contido na variavel 'arquivo'
          li $a1, 0                                        #Atribui para $a1 o valor 0
          li $a2, 0                                        #Atribui para $a2 o valor 0
          syscall                                          #Instru��o respons�vel por chamar o sistema, concedendo a $vo o endere�o do arquivo
          move $s0, $v0                                    #Salva o endere�o do arquivo em $s0, criando uma c�pia
          
      lerArquivo:
          li $v0, 14                                       #Comando para ler o arquivo, no caso o "maze.pgm", atribuindo 14 para $v0
          move $a0, $s0                                    #Concede o endere�o do arquivo em $s0 para $ao, que ser� argumento no 'syscall'
          la $a1, buffer                                   #Concede em $a1 o valor do buffer (128000), guardando-o
          li $a2, 128000                                   #Concede para $a2 a quantidade de bits que ser�o lidas em $a0
          syscall                                          #Instru��o respons�vel por chamar o sistema, concedendo a $vo o endere�o do arquivo
          move $t0, $v0                                    #Salva o endere�o de arquivo de $v0 em $t0
          
          li $v0, 16                                       #Comando para fechar o arquivo, atribuindo 16 para $vo
          syscall                                          #Instru�o respons�vel por chamar o sistema, e assim, fechar o arquivo
          
          la $s0, buffer                                   #Carrega o valor contido em 'buffer' no in�cio de $s0
          add $s7, $s0, $t0                                #Realiza a soma dos regitradores $s0 e $t0, e guarda o resultado em $s7
          
          li $t2, 0                                        #Contador criado, armazenando em $t2 o valor 0
          lb $t3, pula                                     #Guarda em $t3 o c�digo ASCII de nova linha, o 'pula' (\n)
          
       acharTamanho:                                        
          lb $t1, 0($s0)                                   #Guarda em $t1 o byte na primeira posi��o do vetor, realizando o alinhamento de mem
          beq $t1, $t3, contaUm                            #La�o de repeti��o criado, com a condi��o que $t1 == $t3, e assim pula para 'conta1'
          addi $s0, $s0, 1                                 #Caso %t1 != $t3, soma-se %s0 + 1, e armazena em $s0
          j acharTamanho                                    #Comando Jump (j) que retorna ao inicio do loop (achaTamanho)
          
          contaUm:
              addi $s0, $s0, 1                             #Soma-se $s0 + 1 e armazena em $s0, correndo o 'vetor'
              addi $t2, $t2, 1                             #Soma-se $t2 + 1 e armazena em $t2, correndo o contador
              bne $t2, 2, acharTamanho                      #Cria-se la�o de repeti��o para que, como o tamanho est� na terceira linha, se o contador n�o tiver pulado duas vezes de linha retorna ao loop 'achaTamanho'
          
          li $t2, 0                                        #Quando a linha � pulada 2 vezes o contador � reiniciado para ser reutilizado 
          lb $t3, espaco                                   #Carrega, agora, o c�digo ASCII de espa�o em $t3
          
        acharLargura:
          lb $t1, 0($s0)                                   #Carrega em $t1 o byte contido na posi��o atual do 'vetor' ($s0), depois de j� ter corrido em contaUm
          beq $t1, $t3, sair                               #La�o de repeti��o para analisar se $t1 � um espa�o ($t3), se for vai para sair
          mul $t2, $t2, 10                                 #Caso contr�rio multiplicamos o valor contido em $t2 (na primeira vez � 0) por 10
          sub $t1, $t1, 48                                 #Realiza a convers�o do byte em ASCII para decimal, subtraindo 48 o valor de $t1 que � a diferen�a de valores de ASCII p/ decimal
          add $t2, $t2, $t1                                #Soma-se o valor de $t2 (contador de largura) com $t1 (endere�o atual do vetor)
          addi $s0, $s0, 1                                 #Soma-se um p/ $s0, assim "corre" em um a posi��o do vetor
          j acharLargura                                    #Jump para o retorno ao in�cio do loop
          
          sair:
          li $s1, 0                                        #Atribui 0 para $s1
          add $s1, $s1, $t2                                #Soma-se em $s1 o valor de $t2, tornando-o o novo 'contador' de largura
          li $t2, 0                                        #Carrega 0 para $t2, reescrevendo o valor de $t2
          lb $t3, retorna                                  #Carrega, agora, o c�digo ASCII de retorno em $t3
          addi $s0, $s0, 1                                 #Soma-se um p/ $s0, assim "corre" em um o vetor
           
        acharAltura:
          lb $t1, 0($s0)                                   #Carrega em $t1 o byte contido na posi��o atual do 'vetor' ($s0), para n�o precisar 'percorrer' tudo novamente
          beq $t1, $t3, sair2                              #La�o de repeti��o para analisar se o valor em $t1 � o c�digo ASCII de nova linha, se for vai p/ 'sair2' 
          mul $t2, $t2, 10                                 #Caso contr�rio multiplicamos o valor contido em $t2 (na primeira vez � 0) por 10
          sub $t1, $t1, 48                                 #Realiza a convers�o do byte em ASCII para decimal, subtraindo 48 o valor de $t1 que � a diferen�a de valores de ASCII p/ decimal
          add $t2, $t2, $t1                                #Soma-se o valor de $t2 (contador de largura) com $t1 (endere�o atual do vetor)
          addi $s0, $s0, 1                                 #Soma-se um p/ $s0, assim "corre" em um a posi��o do vetor
          j acharAltura                                     #Jump para o retorno do loop 'achaAltura'
          
          sair2:
             li $s2, 0                                     #Atribui 0 para $s2
             add $s2, $s2, $t2                             #Soma-se em $s2 o valor de $t2, tornando-o o novo 'contador1 de altura
             lb $t3, zero                                  #Carrega o c�digo ASCII de 'zero' p/ $t3 
             lb $t4, dois                                  #Carrega o c�digo ASCII de 'dois p/ $t4 (onde 2 seria o in�cio de 255, e por sua vez, o branco)
             
        procuraLab:
          lb $t1, 0($s0)                                   #Carrega em $t1 o primeiro byte contido na posi��o atual do vetor atrav�s de $s0
          beq $t1, $t3, sair3                              #La�o de repeti��o que verifica se o byte contido em $t1 � zero ($t3), se for vai para 'sair3'
          addi $s0, $s0, 1                                 #Casso contr�rio soma-se um em $s0, assim "corre" em um a posi��o do vetor
          j procuraLab                                     #Jump para o retorno do loop 'procuraLab'
          
          sair3:
              move $s3, $s0                                #Carrega em $s3 o $s0, assim fica salvo o in�cio do labirinto
              li $t5, 1                                    #Atribui a $t5 o valor 1, registrador de colunas
              li $t6, 1                                    #Atribui a $t6 o valor 1, registrador de linhas
              li $t7, 0                                    #Atribui em $t7 o valor 0, registrador para as entradas
       
        procuraEntrada:
          lb $t1, 0($s0)                                   #Carrega em $t1 o primeiro byte contido na posi��o atual do vetor atrav�s de $s0
          beq $t1, $t3, olhaEntrada                        #La�o de repeti��o que verifica se $t1 for igual a zero ($t3), vai para 'olhaEntrada'
          beq $t1, $t4, olhaEntrada                        #La�o de repeti��o que verifica se $t1 for igual a dois ($t4), tamb�m vai para 'olhaEntrada'
          addi $s0, $s0, 1                                 #Caso contr�rio, se n�o houver nenhuma igualdade nos dois la�os, soma-se um a $s0, "correndo" em um o vetor
          j procuraEntrada                                 #Jump para o retorno do loop 'procuraEntrada'
          
          olhaEntrada:
               beq $t5, 1, marcaEntrada1                   #La�o de repeti��o que verifica se $t5 for igual a um, se for vai para 'marcaEntrada1'. Sendo a primeira coluna do labirinto
               beq $t5, $s1, marcaEntrada2                 #La�o de repeti��o que verifica se $t5 for igual a $s1 (ultima coluna), se for vai para 'marcaEntrada2'. Sendo a �ltima coluna do labirinto
               beq $t6, 1, marcaEntrada1                   #La�o de repeti��o que verifica se $t6 for igual a um, se for vai para 'marcaEntrada1'. Sendo a primeira linha do labirinto
               beq $t6, $s2, marcaEntrada1                 #La�o de repeti��o que verifica se $t6 for igual a $s2, se for vai para 'marcaEntrada1'. Sendo a �ltima linha do labirinto
               addi $t5, $t5, 1                            #Caso n�o exista igualdade em nenhum dos la�os, soma-se um em $t5, assumindo que uma coluna foi encontrada
               addi $s0, $s0, 1                            #Soma-se um p/ $s0, assim "corre" em um a posi��o do vetor
               j procuraEntrada                            #Jump para retorno do loop 'procuraEntrada'
               
                   marcaEntrada1:
                       addi $t5, $t5, 1                    #Soma-se um em $t5, assumindo que uma coluna foi encontra
                       beq $t1, $t4, salvaEntrada          #La�o de repeti��o que verifica se $t1, posi��o atual do vetor, � igual a dois ($t4), ou seja, branco, e assim uma entrada. Se existir igualdade, vai para 'salvaEntrada'
                       addi $s0, $s0, 1                    #Caso contr�rio, se n�o existir igualdade, soma-se um em $s0, assim "corre" um na posi��o do vetor
                       j procuraEntrada                    #Jump para retorno do loop 'procuraEntrada'
                   
                   marcaEntrada2:
                       li $t5, 1                           #Atribui um para o registrador $t5, reiniciando a contagem
                       addi $t6, $t6, 1                    #Soma-se um em $t6, contando uma nova linha do labirinto
                       beq $t1, $t4, salvaEntrada          #La�o de repeti��o que verifica se %t1, posi��o atual do vetor, � igual a dois ($t4, ou seja, branco, e assim uma entrada. Se existir igualdade, vai para 'salvaEntrada'
                       addi $s0, $s0, 1                    #Caso contr�rio, se n�o existir igualdade, soma-se um em $s0, assim "corre" um na posi��o do vetor
                       j procuraEntrada                    #Jump para retorno do loop 'procuraEntrada'
                       
                       salvaEntrada:
                           beq $t7, 1, salvaSaida          #La�o de repeti��o que verifica se $t7 (que na primeira vez vale 0) � igual a 1. Se existir igualdade vai para 'salvaSaida'
                           addi $t1, $t1, 1                #Caso contr�rio, soma-se um a %t1, que nesse momento valia 2 e passar� a valer 3 (de 255 para 355), assim no labirinto a entrada ficar� marcada pela cor cinza
                           sb $t1, 0($s0)                  #Faz-se a escrita do novo valor obtido na posi��o do vetor $s0, que � a atual
                           add $t7, $t7, 1                 #Soma-se um a $t7, deste modo na pr�xima vez que o la�o for rodado, o sist j� saber� que j� foi encontrada uma entrada marcada
                           addi $s0, $s0, 1                #Soma-se um a $s0, assim corre um para a pr�xima posi��o do vetor $s0
                           j procuraEntrada                #Jump para o retorno do loop 'procuraEntrada'
                       
                       salvaSaida:
                           addi $t1, $t1, 1                #Soma-se um a $t1, que nesse momento valia 2 e passar� a valer 3 (de 255 para 355), assim no labirinto a sa�da (j� que a entrada j� foi encontrada) ficar� marcada pela cor cinza
                           sb $t1, 0($s0)                  #Faz-se a escrita do novo valor obtido na posi��o do vetor %s0, que � a atual
                           li $t5, 0                       #Atribui 0 a $t5, "reiniciando" o registrador de colunas
                           li $t6, 0                       #Atribui 0 a $t6, "reiniciando" o registrador de linhas
                           li $t7, 0                       #Atribui 0 a $t7, "reiniciando" o registrador de entradas
        
        resolveLab:                                        #Depois de marcado a entrada e sa�da, o c�digo segue para a resolu��o do labirinto
          move $s0, $s3                                    #Carrega em $s0 os dados de $s3, retornando ao "in�cio" do labirinto
          achaBranca:                                      
              li $s4, 0                                    #Atribui zero para $s4, sendo o registrador respons�vel por armazenar o n�mero de c�lulas vizinhas pretas
              addi $s0, $s0, 1                             #Soma-se um a $s0, assim "corre" um para a pr�xima posi��o do vetor $s0
              move $s7, $s0                                #Carrega no registrador $s7 os dados de $s0, "guardando" a c�lula trabalhada
              lb $t1, 0($s0)                               #Carrega em $t1 o primeiro byte contido na posi��o atual do vetor $s0
              beq $t1, 0, criaNovoArquivo                  #La�o de repeti��o que verifica se $t1 � igual a zero, ou seja, se chegou ao final do arquivo. Se houver igualdade, vai para 'criaNovoArquivo'
              bne $t1, $t4, achaBranca                     #La�o de repeti��o que verifica se $t1 for diferente (n�o for igual) a dois ($t4). Se houver diferen�a vai para 'achaBranca'
                         
              direita:
                addi $s0, $s0, 1                           #Soma-se um a $s0, assim "corre" um para a pr�xima posi��o do vetor $s0
                lb $t1, 0($s0)                             #Carrega em $t1 o primeiro byte contido na posi��o atual do vetor $s0
                beq $t1, 51, finalDireita                  #La�o de repeti��o que verifica se $t1 for igual a 51 (em ASCII � 3). Se houver igualdade vai para 'finalDireita'
                beq, $t1, $t4, finalDireita                #La�o de repeti��o que verifica se $t1 � igual a $t4, ou seja, se � branco. Se houver igualdade vai para 'finalDireita'
                beq $t1, $t3, marcaVizPretaD               #La�o de repeti��o que verifica se $t1 � igual a $t3, ou seja, se � preta. Se houver igualdade vai para 'marcaVizPretaD'
                j direita                                  #Jump que retorna para 'direita'
                marcaVizPretaD:              
                   addi $s4, $s4, 1                        #Soma-se um a $s4, registrador respons�vel por armazenar o total de c�lulas vizinhas pretas
                finalDireita:
                   move $s0, $s7                           #Carrega no registrador $s0 os dados de $s7, voltando o vetor para o ponto analisado anterior ao 'achaBranca' 
              
              esquerda:
                 subi $s0, $s0, 1                          #Subtrai-se um de $s0, assim "corre" em um para a posi��o anterior do vetor $s0
                 lb $t1, 0($s0)                            #Carrega em $t1 o primeiro byte contido na posi��o atual do vetor $s0
                 beq $t1, 51, finalEsquerda                #La�o de repeti��o que verifica se $t1 for igual a 51 (em ASCII � 3). Se houver igualdade vai para 'finalEsquerda'
                 beq $t1, $t4, finalEsquerda               #La�o de repeti��o que verifica se $t1 � igual a $t4, ou seja, se � branco. Se houver igualdade vai para 'finalEsquerda'
                 beq $t1, $t3, marcaVizPretaE              #La�o de repeti��o que verifica se $t1 � igual a $t3, ou seja, se � preta. Se houver igualdade vai para 'marcaVizPretaE'
                 j esquerda                                #Jump que retorna para 'esquerda'
                 marcaVizPretaE:
                    addi $s4, $s4, 1                       #Soma-se um a $s4, registrador respons�vel por armazenar o total de c�lulas vizinhas pretas
                 finalEsquerda:
                    move $s0, $s7                          #Carrega no registrador $s0 os dados de $s7, voltando o vetor para o ponto analisado anterior ao 'achaBranca'
                    li $t9, 0                              #Atribui zero ao registrador $t9, repos�vel por armazenar a quantidade de c�lulas
              
              emCima:
                 beq $t9, $s1, apontaVizEmCima             #La�o de repeti��o que verifica a igualdade entre $t9 e $s1(armazena a largura do lab). Se existir igualdade, vai para 'apontaVizEmCima'
                 subi $s0, $s0, 1                          #Subtrai-se um de $s0, assim "corre" em um para a posi��o anterior do vetor $s0
                 lb $t1, 0($s0)                            #Carrega em $t1 o primeiro byte contido na posi��o atual do vetor $s0
                 beq $t1, 51, contaUndEmCima               #La�o de repeti��o que verifica se $t1 for igual a 51 (em ASCII � 3). Se houver igualdade vai para 'contaUndEmCima'
                 beq $t1, $t4, contaUndEmCima              #La�o de repeti��o que verifica se $t1 � igual a $t4, ou seja, se � branco. Se houver igualdade vai para 'contaUndEmCima'
                 beq $t1, $t3, contaUndEmCima              #La�o de repeti��o que verifica se $t1 � igual a $t3, ou seja, se � preta. Se houver igualdade vai para 'contaUndEmCima'
                 j emCima                                  #Jump que retorna para 'emCima'
                 contaUndEmCima:
                    addi $t9, $t9, 1                       #Soma-se um a $t9, registrador respons�vel pelo n�mero de c�lulas
                    j emCima                               #Jump que retorna para 'emCima'
                 apontaVizEmCima:
                    beq $t1, $t3, marcaVizPretaC           #La�o de repeti��o que verifica se $1 � igual a $t3, ou seja, preta. Se houver igualdade vai para 'marcaVizPretaC' 
                    j finalEmCima                          #Jump que retorna para 'finalEmCima'
                 marcaVizPretaC:
                    addi $s4, $s4, 1                       #Caso $t1 seja igual a $t3, soma-se um a $s4, registrador respons�vel por armazenar o n�mero de celulas vizinhas pretas
                 finalEmCima:
                    move $s0, $s7                          #Carrega no registrador $s0 os dados de $s7, voltando o vetor para o ponto analisado anterior ao 'achaBranca'
                    li $t9, 0                              #Atribui zero ao registrador $t9, repos�vel por armazenar a quantidade de c�lulas
              
              emBaixo:
                  beq $t9, $s1, apontaVizEmBaixo           #La�o de repeti��o que verifica a igualdade entre $t9 e $s1(armazena a largura do lab). Se existir igualdade, vai para 'apontaVizEmBaixo'
                  addi $s0, $s0, 1                         #Soma-se um a $s0, assim corre um para a pr�xima posi��o do vetor $s0
                  lb $t1, 0($s0)                           #Carrega em $t1 o primeiro byte contido na posi��o atual do vetor $s0
                  beq $t1, 51, contaUndEmBaixo             #La�o de repeti��o que verifica se $t1 for igual a 51 (em ASCII � 3). Se houver igualdade vai para 'contaUndEmBaixo'
                  beq $t1, $t4, contaUndEmBaixo            #La�o de repeti��o que verifica se $t1 � igual a $t4, ou seja, se � branco. Se houver igualdade vai para 'contaUndEmBaixo'
                  beq $t1, $t3, contaUndEmBaixo            #La�o de repeti��o que verifica se $t1 � igual a $t3, ou seja, se � preta. Se houver igualdade vai para 'contaUndEmBaixo'
                  j emBaixo                                #Jump que retorna para 'emBaixo'
                  contaUndEmBaixo:
                      addi $t9, $t9, 1                     #Soma-se um a $t9, registrador respons�vel pelo n�mero de c�lulas
                      j emBaixo                            #Jump que retorna para 'emBaixo'
                  apontaVizEmBaixo:
                      beq $t1, $t3, marcaVizPretaB         #La�o de repeti��o que verifica se $1 � igual a $t3, ou seja, preta. Se houver igualdade vai para 'marcaVizPretaB' 
                      j finalEmBaixo                       #Jump que retorna para 'finalEmBaixo'
                  marcaVizPretaB:
                      addi $s4, $s4, 1                     #Caso $t1 seja igual a $t3, soma-se um a $s4, registrador respons�vel por armazenar o n�mero de celulas vizinhas pretas
                  finalEmBaixo:
                      move $s0, $s7                        #Carrega no registrador $s0 os dados de $s7, voltando o vetor para o ponto analisado anterior ao 'achaBranca'
                      li $t9, 0                            #Atribui zero ao registrador $t9, repos�vel por armazenar a quantidade de c�lulas
              
              bne $s4, 3, achaBranca                       #La�o de repeti��o que verifica se $s4 for diferente de 3 (n�mero de c�lulas vizinhas). Se houver diferen�a vai para 'achaBranca'
              lb $t1, 0($s0)                               #Caso contr�io, carrega em $t1 o primeiro byte contido na posi��o atual do vetor $s
              subi $t1, $t1, 2                             #Subtrai-se $t1 em dois, transformando o primeiro byte em zero
              sb $t1, 0($s0)                               #Faz-se a escrita do novo valor obtido na posi��o do vetor %s0, que � a atual
              j resolveLab                                 #Jump que retorna para 'resolveLab'
              
       criaNovoArquivo:
           li $v0, 13                                      #Atribui para $v0 o valor 13, que � o c�digo para abertura do arquivo
           la $a0, novoArquivo                             #Atribui para $a0 o 'novoArquivo', que � argumento de syscall
           li $a1, 1                                       #Atribui para $a1 o valor 1
           li $a2, 0                                       #Atribui para $a2 o valor 0
           syscall                                         #Instru��o respons�vel por chamar o sistema, concedendo a $vo o endere�o do arquivo
           
       escreveArquivo:
           la $s0, buffer                                  #Atribui a $s0 o 'buffer', voltando para o in�cio
           move $a0, $v0                                   #Carrega em $a0 o valor de $v0, que � o endere�o do arquivo criado
           li $v0, 15                                      #Atribui a $v0 o valor 15, que � o c�digo para a escrita no arquivo
           la $a1, 0($s0)                                  #Atribui para $a1 os dados contidos no buffer(agora em $s0)
           move $a2, $t0                                   #Carrega em $a2 o valor de $v0, onde cont�m caracteres 
           syscall                                         #Instru��o respons�vel por chamar o sistema, concedendo a $vo o endere�o do arquivo
           
           li $v0, 16                                      #Atribui a $v0 o valor 16, assim o $a0 j� cont�m o endere�o do arquivo que ser� fechado. 'li $v0 16' � o c�digo para fechar o arquivo
           syscall                                         #Instru��o respons�vel por chamar o sistema, fechando o arquivo
              
               
          
          
          
                  
