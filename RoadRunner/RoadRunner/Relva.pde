class Relva{
  float x, y, z;
  float tamanho, velocidade;
  
  Relva(float velocidade) {
    x  = random(width);
    y  = random(-500, -50);
    z  = random(0, 20);
    tamanho = random(0,20);
    this.velocidade = velocidade;
  }

  void mover(float velocidade) {
    y =  y + velocidade;
    float queda = map(z, 0, 20, 0, 0.2);
    velocidade = velocidade + queda;

    if (y > height) {
      y = random(-200, -100);
    }

  }

  void mostrar() {
    strokeWeight(random(0,1));
    stroke(random(10), random(200), random(10));
    line(x, y, x, y + tamanho);
  }
}
