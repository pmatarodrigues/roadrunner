class Obstaculo {
  float posicaoX;
  float posicaoY = - 20 ;
  int faixa;
  int objeto = 0;
  int objetoWidth, objetoHeight;
  int xMinimo, xMaximo;

  Obstaculo() {
    posicaoX = random(width/3 + 20, width/2 + width/3/3 - 20);
    //escolherFaixa();                  //atribui uma faixa aleatoria
  }

  void mostrar() {
    //objetos para além de cones apenas aparecem a partir de nivel 30
    if (pontos < 500) {
      objeto = 1;
    }
    if(posicaoY + 100 < 0){
      objeto = (int)random(1,3); 
    }
    //---- Definição dos objetos
    if (objeto == 0){  //aviso
      objetoWidth = 70; 
      objetoHeight = 70;
      shape(aviso, posicaoX, posicaoY, objetoWidth, objetoHeight);
    }
    if (objeto == 1) { //cone
      objetoWidth = 70;
      objetoHeight = 70;
      shape(cone, posicaoX, posicaoY, objetoWidth, objetoHeight);
    }
    if (objeto == 2) { //buraco
      objetoWidth = 100;
      objetoHeight = 170;
      shape(buraco, posicaoX, posicaoY, objetoWidth, objetoHeight);
    }
  }

  void mover(float velocidade) {
    posicaoY += velocidade;
    if(posicaoY > height){
      posicaoY = -5;
      posicaoX = random(width/3 + 20, width/2 + width/3/3 - 20);
      //escolherFaixa();
    }
  }

  void escolherFaixa() {
    faixa =(int) random(0,2);
    if(faixa == 0){
      xMinimo = width/3 + 20;
      xMaximo = width/2;
    }
    if(faixa == 1){
      xMinimo = width/2 + 20;
      xMaximo = width/2 + width/3/3 - 20;
    }
  }
  
  int getObjetoWidth(){
    return objetoWidth;
  }
  
  int getObjetoHeight(){
    return objetoHeight;
  }
  
}
