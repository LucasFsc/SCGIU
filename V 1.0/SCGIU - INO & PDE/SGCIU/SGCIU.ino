//Programa: Leitura e gravacao de cartoes RFID
//Autor: FelipeFlop
//Modificado por: Lucas Ferraz Schlemper

#include <SPI.h>
#include <MFRC522.h>
#include <LiquidCrystal.h>

//Pinos Reset e SS módulo MFRC522
#define SS_PIN 10
#define RST_PIN 9
MFRC522 mfrc522(SS_PIN, RST_PIN);

LiquidCrystal lcd(6, 7, 5, 4, 3, 2);

//Trocando botoes por leitura Serial
//#define pino_botao_le A2
//#define pino_botao_gr A3

MFRC522::MIFARE_Key key;

//String checkUPinicial;                   //recebe flag para iniciar
String checkUP;                         //recebe string que cancela modo de leitura ou gravação
boolean checkUPmodoLeitura = false;     //checar o que é recebido pela serial em modo leitura
boolean checkUPmodoGravacao = false;    //checar o que é recebido pela serial em modo gravacao

boolean checarEstado = false;                   //usado para sair do modo Gravacao em segurança

boolean habilitarEscrita = true;        //serve para habilitar a escrita do metodo quando chamado o mesmo...por exemplo..como o programa
//tem unidade em void o mesmo repete a escrita do modo que eta varias vezes..com isso essa variavel tranca isso

//===============================================
struct dataBase {
  String listaUID[2];
  String nome[2];
  int codigo[2];
} db;



void setup()
{
  //Carregando valores
  //================================================
  db.listaUID[0] = "75 27 AA 6B";
  db.nome[0] = "Lucas";
  db.codigo[0] = 0;
  //================================================
  db.listaUID[1] = "7D 78 16 CB";
  db.nome[1] = "Diego";
  db.codigo[1] = 1;
  //================================================

  //pinMode(pino_botao_le, INPUT);
  //pinMode(pino_botao_gr, INPUT);
  Serial.begin(9600);   //Inicia a serial
  SPI.begin();      //Inicia  SPI bus
  mfrc522.PCD_Init();   //Inicia MFRC522

  //Inicializa o LCD 16x2
  lcd.begin(16, 2);
  logoProjeto();
  mensageminicial();
  //Prepara chave - padrao de fabrica = FFFFFFFFFFFFh
  for (byte i = 0; i < 6; i++) key.keyByte[i] = 0xFF;
}

void loop()
{

  delay(100);

  if (Serial.available() > 0) {
    String checkUPinicial = Serial.readString();
    if (checkUPinicial == "ativarModoLeitura") {
      checkUPmodoLeitura = true;
    } else if (checkUPinicial == "ativarModoGravacao") {
      checkUPmodoGravacao = true;
    }
  }


  //Verifica se o botao modo leitura foi pressionado
  //trocando metodos por leitura serial
  //int modo_le = digitalRead(pino_botao_le);

  if (checkUPmodoLeitura == true) {
    lcd.clear();
    //Serial.println("Modo leitura selecionado");
    if (habilitarEscrita == true) {
      lcd.setCursor(2, 0);
      lcd.print("Modo leitura");
      lcd.setCursor(3, 1);
      lcd.print("selecionado");
      //while (digitalRead(pino_botao_le) == 1) {}
      delay(800);
      habilitarEscrita = false;
    }
    modo_leitura();
    return;
  }

  //Verifica se o botao modo gravacao foi pressionado
  //int modo_gr = digitalRead(pino_botao_gr);

  if (checkUPmodoGravacao == true) {
    lcd.clear();
    //Serial.println("Modo gravacao selecionado");
    lcd.setCursor(2, 0);
    lcd.print("Modo gravacao");
    lcd.setCursor(3, 1);
    lcd.print("selecionado");
    //while (digitalRead(pino_botao_gr) == 1) {}
    modo_gravacao();
    return;
  }
}

void logoProjeto() {
  lcd.setCursor(5, 0);
  lcd.print("PROJETO");
  lcd.setCursor(5, 1);
  lcd.print("SGCIU");
  delay(800);
}

void mensageminicial()
{
  //Serial.println("\nSelecione o modo leitura ou gravacao...");
  Serial.println();
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Selecione o modo");
  lcd.setCursor(0, 1);
  lcd.print("leitura/gravacao");
}

void mensagem_inicial_cartao()
{
  Serial.println("Aproxime o seu cartao do leitor...");
  lcd.clear();
  lcd.print(" Aproxime o seu");
  lcd.setCursor(0, 1);
  lcd.print("cartao do leitor");
}

void modo_leitura()
{

  while (checkUPmodoLeitura != false) {
    mensagem_inicial_cartao();
    //Aguarda cartao
    while ( ! mfrc522.PICC_IsNewCardPresent())
    {
      if (Serial.available() > 0) {
        if (Serial.readString() == "cancelarModoL/G") {
          checkUPmodoLeitura = false;
          //checkUPinicial = "";
          habilitarEscrita = true;
          lcd.clear();
          mensageminicial();
          asm volatile ("  jmp 0"); //reset
          return;
        }
      }
      delay(100);
    }
    if ( ! mfrc522.PICC_ReadCardSerial())
    {
      return;
    }
    //Mostra UID na serial
    //Serial.print("UID da tag : ");

    String conteudo = "";
    byte letra;
    for (byte i = 0; i < mfrc522.uid.size; i++)
    {
      Serial.print(mfrc522.uid.uidByte[i] < 0x10 ? " 0" : " ");
      Serial.print(mfrc522.uid.uidByte[i], HEX);
      conteudo.concat(String(mfrc522.uid.uidByte[i] < 0x10 ? " 0" : " "));
      conteudo.concat(String(mfrc522.uid.uidByte[i], HEX));
    }
    conteudo.toUpperCase();
    for (int i = 0; i < 3; i++) {
      if (conteudo.substring(1) == db.listaUID[i]) //Lendo chaveiros
      {
        //Serial.println("Este é o conteudo: " + conteudo); //Para exibir o conteudo sem a utilização do processing
        Serial.write(db.codigo[i]);
      }
    }//FINAL DO FOR

    
    //Obtem os dados do setor 1, bloco 4 = Nome
    byte sector         = 1;
    byte blockAddr      = 4;
    byte trailerBlock   = 7;
    byte status;
    byte buffer[18];
    byte size = sizeof(buffer);

    //Autenticacao usando chave A
    status = mfrc522.PCD_Authenticate(MFRC522::PICC_CMD_MF_AUTH_KEY_A,
                                      trailerBlock, &key, &(mfrc522.uid));
    if (status != MFRC522::STATUS_OK) {
      Serial.print(F("PCD_Authenticate() failed: "));
      Serial.println(mfrc522.GetStatusCodeName(status));
      return;
    }
    status = mfrc522.MIFARE_Read(blockAddr, buffer, &size);
    if (status != MFRC522::STATUS_OK) {
      Serial.print(F("MIFARE_Read() failed: "));
      Serial.println(mfrc522.GetStatusCodeName(status));
    }

    //Mostra os dados do nome no Serial Monitor e LCD
    lcd.clear();
    lcd.setCursor(0, 0);
    for (byte i = 1; i < 16; i++)
    {
      //Serial.print(char(buffer[i]));
      lcd.write(char(buffer[i]));
    }
    Serial.println();

    //Obtem os dados do setor 0, bloco 1 = Sobrenome
    sector         = 0;
    blockAddr      = 1;
    trailerBlock   = 3;

    //Autenticacao usando chave A
    status = mfrc522.PCD_Authenticate(MFRC522::PICC_CMD_MF_AUTH_KEY_A,
                                      trailerBlock, &key, &(mfrc522.uid));
    if (status != MFRC522::STATUS_OK)
    {
      Serial.print(F("PCD_Authenticate() failed: "));
      Serial.println(mfrc522.GetStatusCodeName(status));
      return;
    }
    status = mfrc522.MIFARE_Read(blockAddr, buffer, &size);
    if (status != MFRC522::STATUS_OK)
    {
      Serial.print(F("MIFARE_Read() failed: "));
      Serial.println(mfrc522.GetStatusCodeName(status));
    }
    //Mostra os dados do sobrenome no Serial Monitor e LCD
    lcd.setCursor(0, 1);
    for (byte i = 0; i < 16; i++)
    {
      //Serial.print(char(buffer[i]));
      lcd.write(char(buffer[i]));
    }
    //Serial.println();

    // Halt PICC
    mfrc522.PICC_HaltA();
    // Stop encryption on PCD
    mfrc522.PCD_StopCrypto1();
    delay(3000);
    //mensageminicial();
  }
}















//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX



















void modo_gravacao()
{
  boolean LCD = false;
  boolean checkUPsair = true;

  //while(checkUPsair != false){
  //checkUPmodoGravacao = false;
  //checkUPinicial = "";



  //Aguarda cartao
  while ( ! mfrc522.PICC_IsNewCardPresent()) {
    delay(100);
    if (Serial.available() > 0) {
      if (Serial.readString() == "cancelarModoL/G") {
        lcd.clear();
        asm volatile (" jmp 0");
      }
    }
  }
  if ( ! mfrc522.PICC_ReadCardSerial()) {
    return;
  }

  /*
    //Mostra UID na serial
    Serial.print(F("UID do Cartao: "));    //Dump UID
    for (byte i = 0; i < mfrc522.uid.size; i++)
    {
    Serial.print(mfrc522.uid.uidByte[i] < 0x10 ? " 0" : " ");
    Serial.print(mfrc522.uid.uidByte[i], HEX);
    }
    //Mostra o tipo do cartao
    Serial.print(F("\nTipo do PICC: "));
    byte piccType = mfrc522.PICC_GetType(mfrc522.uid.sak);
    Serial.println(mfrc522.PICC_GetTypeName(piccType));
  */

  byte buffer[34];
  byte block;
  byte status, len;
  lcd.clear();
  lcd.print("Aguardando");
  lcd.setCursor(0, 1);
  lcd.print("Sobrenome");
  len = 0;
  Serial.setTimeout(20000L);
  len = Serial.readBytesUntil('#', (char *) buffer, 30);
  lcd.clear();
  lcd.print("Sobrenome");
  lcd.setCursor(0, 1);
  lcd.print("Recebido");
  delay(1000);
  for (byte i = len; i < 30; i++) buffer[i] = ' ';

  block = 1;
  //Serial.println(F("Autenticacao usando chave A..."));
  status = mfrc522.PCD_Authenticate(MFRC522::PICC_CMD_MF_AUTH_KEY_A,
                                    block, &key, &(mfrc522.uid));
  if (status != MFRC522::STATUS_OK) {
    Serial.print(F("PCD_Authenticate() failed: "));
    Serial.println(mfrc522.GetStatusCodeName(status));
    return;
  }

  //Grava no bloco 1
  status = mfrc522.MIFARE_Write(block, buffer, 16);
  if (status != MFRC522::STATUS_OK) {
    Serial.print(F("MIFARE_Write() failed: "));
    Serial.println(mfrc522.GetStatusCodeName(status));
    return;
  }

  block = 2;
  //Serial.println(F("Autenticacao usando chave A..."));
  status = mfrc522.PCD_Authenticate(MFRC522::PICC_CMD_MF_AUTH_KEY_A,
                                    block, &key, &(mfrc522.uid));
  if (status != MFRC522::STATUS_OK) {
    Serial.print(F("PCD_Authenticate() failed: "));
    Serial.println(mfrc522.GetStatusCodeName(status));
    return;
  }

  //Grava no bloco 2
  status = mfrc522.MIFARE_Write(block, &buffer[16], 16);
  if (status != MFRC522::STATUS_OK) {
    Serial.print(F("MIFARE_Write() failed: "));
    Serial.println(mfrc522.GetStatusCodeName(status));
    return;
  }
  
  lcd.clear();
  lcd.print("Aguardando");
  lcd.setCursor(0, 1);
  lcd.print("Nome");
  len = 0;
  Serial.setTimeout(20000L);
  len = Serial.readBytesUntil('#', (char *) buffer, 20);

  for (byte i = len; i < 20; i++) buffer[i] = ' ';

  block = 4;
  //Serial.println(F("Autenticacao usando chave A..."));
  status = mfrc522.PCD_Authenticate(MFRC522::PICC_CMD_MF_AUTH_KEY_A,
                                    block, &key, &(mfrc522.uid));
  if (status != MFRC522::STATUS_OK) {
    Serial.print(F("PCD_Authenticate() failed: "));
    Serial.println(mfrc522.GetStatusCodeName(status));
    return;
  }

  //Grava no bloco 4
  status = mfrc522.MIFARE_Write(block, buffer, 16);
  if (status != MFRC522::STATUS_OK) {
    Serial.print(F("MIFARE_Write() failed: "));
    Serial.println(mfrc522.GetStatusCodeName(status));
    return;
  }

  block = 5;
  //Serial.println(F("Authenticating using key A..."));
  status = mfrc522.PCD_Authenticate(MFRC522::PICC_CMD_MF_AUTH_KEY_A,
                                    block, &key, &(mfrc522.uid));
  if (status != MFRC522::STATUS_OK) {
    Serial.print(F("PCD_Authenticate() failed: "));
    Serial.println(mfrc522.GetStatusCodeName(status));
    return;
  }

  lcd.clear();
  lcd.print("Nome recebido");
  delay(1000);

  //Grava no bloco 5
  status = mfrc522.MIFARE_Write(block, &buffer[16], 16);
  if (status != MFRC522::STATUS_OK) {
    Serial.print(F("MIFARE_Write() failed: "));
    Serial.println(mfrc522.GetStatusCodeName(status));
    //return;
  }
  else
  {
    Serial.println(F("Dados gravados com sucesso!"));
    lcd.clear();
    lcd.print("Gravacao OK!");
  }

  len = 0;


  mfrc522.PICC_HaltA(); // Halt PICC
  mfrc522.PCD_StopCrypto1();  // Stop encryption on PCD
  delay(1500);
  asm volatile ("  jmp 0"); //reset
}//FINAL DO VOID DE GRAVACAO




