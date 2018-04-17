class Traco {
  float x;
  float posicaoY;
  float yLinha1, yLinha2;

  Traco() {
    x = width/2 - 5;
    yLinha1 = 2 * -height/5;
    yLinha2 = 4 * -height/5;
  }

  void mostrar() {
    fill(255);
    noStroke();
    
    rect(width/2 - 5, posicaoY, 10, 60); 
    rect(width/2 - 5, yLinha1, 10, 60);
    rect(width/2 - 5, yLinha2, 10, 60);
  }

  void mover(float velocidade) {
    posicaoY += velocidade;
    yLinha1 += velocidade;
    yLinha2 += velocidade;
    
    if (posicaoY > height) {
      posicaoY = -height/3;
    } 
    if (yLinha1 > height) {
      yLinha1 = - height/3;
    }if (yLinha2 > height) {
      yLinha2 = 2 * -height/3; 
    }
  }
  
}
