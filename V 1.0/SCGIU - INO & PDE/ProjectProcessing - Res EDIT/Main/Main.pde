//codigo beta, refatorar o mesmo após terminar
//tela de 1346x1022
//metade da horizontal = 673
//metade da vertical = 511


import controlP5.*;
import cc.arduino.*;
import processing.serial.*; //Importa a biblioteca para abrir uma comunicação Serial

ProcessamentoImagens pim = new ProcessamentoImagens();

Serial myPort; //Instância a biblioteca para a comuniação Serial

ControlP5 cp5; //instancia a bbl do controlP5

//botoes instanciados
controlP5.Button botaoTelaPrinciapalLeitura;    //botao para iniciar funcao de leitura
controlP5.Button botaoTelaPrinciapalGravacao;   //botao para iniciar funcao de gravacao

controlP5.Button botaoTelaPrinciapalSair;       //botao para sair do programa
controlP5.Button botaoSairLG;                   //botao para sair do programa

//tela instanciada
controlP5.Textfield telaGravacaoSobrenome;      //input de text field para o sobrenome
controlP5.Textfield telaGravacaoNome;           //input de text field para o nome         

controlP5.Button botaoSubmit;                   //diferente do Button ele só inicia seu codigo após ser clicado(ao que parece)
static int nmrPassos = 0;                       //numero de passos realizados durante a função do botaoSubmit para ter controle da sequencia de envio do sobrenome e depois nome;

String sobrenome, nome = "";

int valorRecebido; //Cria uma variável para armazenas o valor recebido pela seria

//int codeLucas = 0;

int posX, posY = 0; //posicoes da tela

//int posAux = 0; //auxiliar da posicao da tela

int statusInicial = 0;

//modo antigo, utilizando classe instanciada para carregar as imagens
  //PImage Lucas;
  //PImage Diego;
  //PImage Logo;

long lastTime = 0; //ultimo tempo lido, usado para temporizar o programa

int cartaoLido = 0; //serve para indicar se a leitura ja foi realizada, quantidade de cartões lidos

boolean estadoModoLeitura = true;
boolean estadoModoGravacao = true;
boolean estadoSairDoPrograma = true;
boolean aguardarSaida = true;





//                                                        PARA O ARDUINO
//para fazer de forma correta o metodo de gravação fazer um while((Serial.read() != *alguma coisa*) || (statusMetodo == "ok"))
//entao o programa pode ser cancelado no meio da operacao ou no final se tudo correr bem o statusMetodo receber "ok" lembrando que
//toda vez que status for "ok" ele deve ser alterado apos sair do while.
//Utilizar essa função para ler a string para o Arduino Serial.readString() 

public void setup()
{

  fullScreen();
  
  
  lastTime = millis();
  
  String portName = Serial.list()[0]; //Lista as portas COM (Serial) encontradas
                                      //Pega a primeira porta (Posição 0 em "Serial.list()[0]" e
                                      //armazena na variável portName
                                      //Se você tiver mais de uma porta COM, identifique qual a do Garagino/Arduino 
  
  myPort = new Serial(this, portName, 9600); //Abre uma comunicação Serial com baud rate de 9600
  
  
  ProcessamentoImagens pim = new ProcessamentoImagens();
  
  background(0);
  background(pim.carregarImagemInicial());
  
  
  //size(800, 800); //Define o tamanho da tela
  
  
  //Remover comentarios se não utilizar a classe para multimodo
  //Carrega as imagens e armazena elas em suas respectivas instâncias
  //Lucas = loadImage("megaMan.jpg");
  //Diego = loadImage("");
  //Logo = loadImage("logo.jpg");
  //==============================================================*/
  
  //inicia a tela com logo, desenhar nova tela com botoes
  //translate(width/2, height/2);
 /*
 cp5 = new ControlP5(this);
  cp5.addButton("teste")
     .setValue(0)
     .setPosition(100,100)
     .setSize(200,20)
     ;
  */
  
}


public void draw(){
 
  if(millis() - lastTime > 1500 && statusInicial == 0){
    background(0);
    statusInicial = 1;
    iniciarCP5();
  }
  
  ProcessamentoImagens pim = new ProcessamentoImagens();
  ListaDeDados ldd = new ListaDeDados();
  

  //CONSIDERAÇÔES DO PROJETO
  //AQUI VAI O MENU
  //Criar o menu de forma que consiga via função mouseClicked() que roda independente, iniciar a partir de botoes,
  //esses botoes devem ter nomes diferentes, suas funções é ficar alterando variaveis booleans de estado para verfificar o estado da situação, 
  //no void draw() criar if condicionais que receber esses estados(status ou situação atual) para iniciar uma parte do codigo
  //o padrao dos botoes sera btn ou botao, seguido do nome do que ele faz, exemplo de codigo sem saber como funciona o mouse clicked ainda
  //
  //  no mouse clicked com o clique do mouse sobre o botao btnIniciarLeituraPassiva ele retorna estadoModoLeitura = true
  //  no draw um if aguarda essa variavel ser iniciada como true considerando que ele seja carregada no inicio como false
  //  while(estadoLeituraPassiva == true){ inicia o codigo da leitura serial que esta logo abaixo }
  //
  //  para sair deste while um botao sairLeituaPassiva deve estar na tela e somente na tela de leituraPassiva para quando clicado o estadoLeituraPassiva receber false e
  //  não operar o while que faz a parte correspondente
  //
  //  fazer o programa depender assim como o este de uma verificação serial de dados para iniciar outros "ifs" da vida:
  //
  //     if(Serial.available()> 0) //Se algo for recebido pela serial
  //      {
  //        valor_recebido = Serial.read(); //Armazena o que foi recebido na variável valor_recebido
  //
  //        if(valor_recebido == dado que eu desejo){faz leitura em modo passivo, ou pode fazer gravação}
  //
  //  implemetar isso para todas as situações, que são: - Modo de leitura passiva, depender da serial para ativar a leitura de dados atraves de uma flag,
  //                                                    - Modo de gravação agora pela serial, descartar o programa de modo somente leitura se a implementação der certo(eu espero)
  //                                                      e utilizar o programa de modo leitura gravação, mas agora com os botoes virtuais, sendo que o arduino deve receber 
  //                                                      pela serial uma flag "valorRecebido = Serial.read() "que autoriza dentro de um if começar o programa
  //                                                      agora todo o programa dependera disso, inclusive o modo leitura dependera da flag, mas agora como o modo de leitura
  //                                                      do programa So_Ler só retornava a UID e comparava, o modo Le_Escreve le a UID e tambem um char que é o nome
  //                                                      da pra continuar usando o ID como ponto de referencia entre as tabelas de dados
  
  
  //MODO MOUSE PRESSED PARA SAIR
  /*
  if (mousePressed && (mouseButton == RIGHT) && (estadoModoLeitura == true)) {
     estadoModoLeitura = false;
     estadoModoGravacao = false;
     posX = 0;
     posY = 0;
     cartaoLido = 0;
     statusInicial = 0;
     permiss = true;
   } 
   */
  
  //MODO LEITURA
  while (myPort.available() > 0) //Se algo for recebido pela serial
  {
    valorRecebido = myPort.read(); //Armazena o que foi lido dentro da variável valor recebido
  
  if(estadoModoLeitura == true){
  //multi modo de leitura com classe instanciada
  
  for(int i = 0; i < 2; i++){
      if(valorRecebido == ldd.listaCodigoRecebido[i] && cartaoLido < 16){
        PImage code = pim.carregarImagem(ldd.listaCodigoRecebido[i]);
          image(code,posX,posY);
          posX += 286.5;
          if(posX >= 1146){
            posY += 274;
            posX = 0;
          }
        lastTime = millis(); //recebe o ultimo tempo lido
        ++cartaoLido; //sai fora do if quando cartãoLido++ 
        
    }
    }
    }
  }
  
  //atualiza a tela pela cada 3 segundos se forem realizadas mais de  15 leituras,
  if ( millis() - lastTime > 1500 && cartaoLido >= 15) 
  {
    image(pim.redefinirFundo(),0,0);
    lastTime = millis();
    cartaoLido = 0;
    posX = 0;
    posY = 0;
  }
  
  //=================================================================================================================================================================
  //println(millis() - lastTime);  
  
 
  /*if(cartaoLido >15){
    image(pim.redefinirFundo(),0,0);
  }*/
  
  //carregando valores na classe imagem
  /*
  int[] listaCodigoRecebido = new int[3];
  listaCodigoRecebido[0] = 0;
  listaCodigoRecebido[1] = 1;
  */
  
  //===============================================================
    //Não deletar, este é o mono modo de leitura, descomentar se for utilizado
    /*
    for(int i = 0; i < 3; i++){
      while(valorRecebido == listaCodigoRecebido[i] && status == 0){
        background(im.checarId(listaCodigoRecebido));
        lastTime = millis(); //recebe o ultimo tempo lido
        status = 1;
      }
    }
  }
  */
  //================================================================
  
}

public void Leitura(){
  estadoModoLeitura = !estadoModoLeitura;
  if(estadoModoLeitura == true){
    botaoTelaPrinciapalLeitura.hide();
    botaoTelaPrinciapalGravacao.hide();
    botaoTelaPrinciapalSair.hide();
    image(pim.redefinirFundo(),0,0);
    botaoSairLG.show();
    myPort.write("ativarModoLeitura");
  }
}

public void Gravacao(){
  estadoModoGravacao = !estadoModoGravacao;
  if(estadoModoGravacao == true){
    botaoTelaPrinciapalLeitura.hide();
    botaoTelaPrinciapalGravacao.hide();
    botaoTelaPrinciapalSair.hide();
    image(pim.carregarGSobrenome(),0,0);
    botaoSairLG.show();
    telaGravacaoSobrenome.show();
    botaoSubmit.show();
    myPort.write("ativarModoGravacao");
  }
}

public void SairModos(){
  if(estadoModoLeitura == true){
    posX = 0;
    posY = 0;
    cartaoLido = 0;
    estadoModoLeitura = !estadoModoLeitura;
    botaoSairLG.hide();
    myPort.write("cancelarModoL/G");
    background(pim.telaAguardar());
    botaoTelaPrinciapalLeitura.show();
    botaoTelaPrinciapalGravacao.show();
    botaoTelaPrinciapalSair.show();
  }else if(estadoModoGravacao == true){
    nmrPassos = 0;
    estadoModoGravacao = !estadoModoGravacao;
    botaoSairLG.hide();
    myPort.write("cancelarModoL/G");
    telaGravacaoSobrenome.hide();
    telaGravacaoNome.hide();
    telaGravacaoSobrenome.clear();
    telaGravacaoNome.clear();
    botaoSubmit.hide();
    background(pim.telaAguardar());
    botaoTelaPrinciapalLeitura.show();
    botaoTelaPrinciapalGravacao.show();
    botaoTelaPrinciapalSair.show();
  }
}

public void Submit(){
  
  if(estadoModoGravacao == true){
    

    //este if serve para saber de qual campo em instancia a variavel vai receber o getText();
    if(nmrPassos == 0){
      clear();
      sobrenome = cp5.get(Textfield.class,"sobrenome").getText();

      
      byte[] sobrenomeByte = sobrenome.getBytes();
      for(int i =0; i < sobrenomeByte.length; i++){
          myPort.write(sobrenomeByte[i]);
      }
      myPort.write('#');
      
      
      telaGravacaoSobrenome.hide();
      telaGravacaoNome.show();
      nmrPassos = 1;
      background(pim.carregarGNome());
    }
    
    else if (nmrPassos == 1){
      clear();
      nome = cp5.get(Textfield.class,"nome").getText();
      
      
      byte[] nomeByte = nome.getBytes();
      for(int i =0; i < nomeByte.length; i++){
        myPort.write(nomeByte[i]);
      }
      myPort.write('#');
      
      
      clear();
      telaGravacaoNome.hide();
      telaGravacaoSobrenome.hide();
      botaoSubmit.hide();
      botaoSairLG.hide();

      //myPort.write("cancelarModoL/G");
      background(pim.telaAguardar());
      estadoModoGravacao = !estadoModoGravacao; 
      
      botaoTelaPrinciapalLeitura.show();
      botaoTelaPrinciapalGravacao.show();
      botaoTelaPrinciapalSair.show();
      nmrPassos = 0;
      //botaoSairModoGravacao.show();
    }
    }
}
    /*
    else if (nmrPassos == 2){
      clear();
      telaGravacaoNome.hide();
      telaGravacaoSobrenome.hide();
      botaoSubmit.hide();
      botaoSairLG.hide();
      nmrPassos = 0;
      myPort.write("cancelarModoL/G");
      background(pim.telaAguardar());
      botaoTelaPrinciapalLeitura.show();
      botaoTelaPrinciapalGravacao.show();
      botaoTelaPrinciapalSair.show();
    }
    */
/*
public void SairModoGravacao(){
  aguardarSaida = !aguardarSaida;
  if(aguardarSaida == true){
    myPort.write("cancelarModoL/G");
    botaoSairModoGravacao.hide();
    background(pim.telaAguardar());
    botaoTelaPrinciapalLeitura.show();
    botaoTelaPrinciapalGravacao.show();
    botaoTelaPrinciapalSair.show();
    println("OK MEU");
  }
}
*/

public void SairDoPrograma(){
  estadoSairDoPrograma = !estadoSairDoPrograma;
  if(estadoSairDoPrograma == true){
    exit();
  }
}

public void iniciarCP5(){
  //botoes instanciados Classe obj
  
  PFont font = createFont("arial", 20);
  
  background(pim.telaAguardar()); //So funciona porque a imagem é do tamanho do background devido usar em fullscreen
  
  cp5 = new ControlP5(this);
  
  botaoTelaPrinciapalLeitura = 
  cp5.addButton("Leitura")
     .setLabel("Modo de Leitura")
     .setValue(0)
     .setPosition(285,343)
     .setSize(200,20)
     ;
  
  botaoTelaPrinciapalGravacao =
  cp5.addButton("Gravacao")
     .setLabel("Modo de Gravacao")
     .setValue(0)
     .setPosition(285,373)
     .setSize(200,20)
     ;
  
  botaoTelaPrinciapalSair = 
  cp5.addButton("SairDoPrograma")
     .setLabel("Sair")
     .setValue(0)
     .setPosition(285,403)
     .setSize(200,20)
     ;
  
  botaoSairLG =
  cp5.addButton("SairModos")
     .setLabel("Voltar")
     .setValue(0)
     .setPosition(0,0)
     .setSize(200,20)
     ;
  botaoSairLG.hide();  
 
 botaoSubmit =  
   cp5.addButton("Submit")
     .setLabel("Enviar")
     .setValue(0)
     .setPosition(583,435)
     .setSize(200,20)
     ;
 botaoSubmit.hide();
     
 telaGravacaoSobrenome = 
   cp5.addTextfield("sobrenome")
     .setLabel("")
     .setFont(font)
     .setPosition(533, 361)
     .setSize(300, 40)
     .setAutoClear(false)
     ;
  telaGravacaoSobrenome.hide();
  
  telaGravacaoNome = 
   cp5.addTextfield("nome")
     .setLabel("")
     .setFont(font)
     .setPosition(533, 361)
     .setSize(300, 40)
     .setAutoClear(false)
     ;
  telaGravacaoNome.hide();
   
}