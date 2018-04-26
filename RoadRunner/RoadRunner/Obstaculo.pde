class Obstaculo {
  float posicaoX;
  float posicaoY = - 20 ;
  int objetoWidth, objetoHeight;
  int objeto;

  Obstaculo() {
    posicaoX = random(width/3 + 20, width/2 + width/3/3 - 20);
  }

  void mostrar() {
    //objetos para além de cones apenas aparecem a partir dos 60 pontos
    if (obstaculo.posicaoY < 0) {
      if (pontos < 60) {
        obstaculo.objeto = 0;
      } else {
        obstaculo.objeto = (int)random(0, 2);
      }
    }
    //---- Definição dos objetos
    if (objeto == 0) { //cone
      objetoWidth = 70;
      objetoHeight = 70;
      shape(cone, posicaoX, posicaoY, objetoWidth, objetoHeight);
    }
    if (objeto == 1) { //buraco
      objetoWidth = 100;
      objetoHeight = 170;
      shape(buraco, posicaoX, posicaoY, objetoWidth, objetoHeight);
    }
  }

  void mover(float velocidade) {
    posicaoY += velocidade;
    if (posicaoY > height) {
      posicaoY = -5;
      posicaoX = random(width/3 + obstaculo.getObjetoWidth()/2, width/2 + width/3/3 - obstaculo.getObjetoWidth()/2);
      //posicaoX = random(width/3 + 20, width/2 + width/3/3 - 20);
      //escolherFaixa();
    }
  }
  int getObjetoWidth() {
    return objetoWidth;
  }

  int getObjetoHeight() {
    return objetoHeight;
  }
}
