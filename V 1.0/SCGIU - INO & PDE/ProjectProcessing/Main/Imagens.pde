public class ProcessamentoImagens{
  
  //Logo em 480x480
  //Imagens de fotos em 220x220
  
  PImage foto;
  PImage imagemInicial;
  PImage redefinir;
  PImage telaAguardar;
  PImage telaGNome;
  PImage telaGSobrenome;
  
  
  public PImage carregarImagem(int id){
    if(id == 0){
      foto = loadImage("megaMan.jpg");    
    }else if(id == 1){
      foto = loadImage("megaMan1.jpg");
    }
    return foto;
  }
   
  public PImage carregarImagemInicial(){
    imagemInicial = loadImage("logo.jpg");
    return imagemInicial;
  }
  
  public PImage redefinirFundo(){
    redefinir = loadImage("redefinir.jpg");
    return redefinir;
  }
  
  public PImage telaAguardar(){
    telaAguardar = loadImage("telaAguardar.jpg");
    return telaAguardar;
  }
  
  public PImage carregarGNome(){
    telaGNome = loadImage("nome.jpg");
    return telaGNome;
  }
  
  public PImage carregarGSobrenome(){
    telaGSobrenome = loadImage("sobrenome.jpg");
    return telaGSobrenome;
  }
  
}