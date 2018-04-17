class Carro{
 float posicaoX, posicaoY;

 Carro(){
  for (int b = 0; b < faces.length; b++) {
   posicaoX = -faces[b].x + 675;
   posicaoY =  faces[b].y + 400;
  }
  carro = loadImage("mercedes.png");
  carro.resize(70, 140);
  image(carro, width/2 - 140, height - 130); 
 }
  
  
}
