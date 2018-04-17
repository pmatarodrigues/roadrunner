import processing.sound.*;
import processing.video.*;
import gab.opencv.*;
import java.awt.Rectangle;
//VIDEO
OpenCV opencv;
Capture camera;
//AUDIO
AudioIn inputAudio;
Amplitude amplitude;
float volume;
float limite;

float velocidade;
float posicaoLinha;
float z;
int objeto;
boolean aJogar = false;
boolean carroEscolhido = false;

float xCarro, yCarro;

//-------- Objetos
PImage automovel, automovelInicial;
PImage tanque, tanqueInicial;
PImage carro;
PShape buraco;
PShape cone;
PShape barreira;
PShape aviso;


// ------- Informações de Jogo
int pontos = 2;
boolean gameOver;

//---- Tracejado
Traco[] tracejado = new Traco[200];
Relva[] relvado = new Relva[200];
Estrada estrada = new Estrada();
ArrayList<Obstaculo> obstaculos = new ArrayList<Obstaculo>();

//---- Cara
Rectangle[] faces;

Obstaculo obstaculo = new Obstaculo();
Traco traco = new Traco();

void setup() {

  inputAudio = new AudioIn(this, 0);
  inputAudio.start();
  amplitude = new Amplitude(this);
  amplitude.input(inputAudio);

  // ------------- Janela
  z = random(0, 10);
  size(1200, 600);

  // ------------- Definir Camera
  camera = new Capture(this, 320, 240);
  camera.start();
  // -------------- Movimento
  velocidade = map(z, 10, 20, 11, 20);

  // ------------- Ciar ambiente
  for (int i = 0; i < relvado.length; i++) {
    tracejado[i] = new Traco();
    relvado[i] = new Relva(velocidade);
  }
  //------------ Criar Carro
  automovel = loadImage("mercedes.png");
  tanque = loadImage("tanque.png");
  //carro = tanque;
  //------------ Criar Obstaculos
  buraco = loadShape("buraco.svg");
  cone = loadShape("cone.svg");
  barreira = loadShape("barreira.svg");
  aviso = loadShape("aviso.svg");
}


void draw() { 
  //Analisar o volume e definir o limite
  volume = amplitude.analyze();
  limite = 0.5;
  if (!aJogar) {
    fill(255);
    menu();
  } else
    if (!carroEscolhido) {
      selecionaCarro();
    } else {
      if (!gameOver) {
        textAlign(LEFT);
        //----------- Atribuir valor de velocidade
        velocidade += 0.5 ; //aumentar velocidade gradualmente
        carregarAmbiente();
        pontos += 1;
        apresentarCamera();
        //----------- Detetar Cara
        opencv = new OpenCV(this, camera);
        opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
        faces = opencv.detect();
        scale(-1, 1); //--- voltar a inverter camera
        noFill();
        stroke(0, 255, 0);
        strokeWeight(3);

        //--------- Carregar Carro
        for (int b = 0; b < faces.length; b++) {
          if (carro == tanque) {
            carro.resize(80, 85);
          }
          if (carro == automovel) {
            carro.resize(70, 140);
          }
          xCarro = -faces[b].x + 675;
          yCarro = faces[b].y + 400;
          image(carro, xCarro, yCarro, carro.width, carro.height);
        }
        // -------- Pontos
        apresentarPontuacao();

        //--------- Em caso de colisão entre o obstaculo e o carro
        for ( int c = 0; c < obstaculos.size(); c++) {
          Obstaculo obstaculo = obstaculos.get(c);
          if (colisao(obstaculo)) {
            gameOver = true;
          }
        }

        if (keyPressed) {
          if (key == ' ') {
            carroEscolhido = false;
            automovel = loadImage("mercedes.png");
            tanque = loadImage("tanque.png");
          }
        }
      } else {
        //ECRA DE GAMEOVER
        background(#66BB6A);
        textAlign(CENTER);
        textSize(40);
        text("GAME OVER", width/2, height/2 - 50);
        text("Pontuação: " + pontos, width/2, height/2 + 50);
        text("Clique para tentar novamente", width/2, height/2);
        if (keyPressed) {
          gameOver = false;
          textAlign(CENTER);
          obstaculo.posicaoY = -2;
          pontos = 0;
          velocidade = map(z, 0, 20, 1, 20);
        }
      }
    }
}


//------ CARREGAR AMBIENTE
void carregarAmbiente() {
  background(#66BB6A);
  //----------- Desenhar Relva
  for (int i = 0; i < relvado.length; i++) {
    relvado[i].mostrar();
    relvado[i].mover(velocidade);
  }
  //----------- Desenhar Estrada
  estrada.mostrar();
  //----------- Desenhar Tracejado
  for (int i = 0; i < tracejado.length; i++) {
    tracejado[i].mostrar();
    tracejado[i].mover(velocidade);
  } 
  //----------- Carregar Obstaculos
  if (obstaculo.posicaoY + obstaculo.getObjetoHeight() < 0) {  //menor que zero para que não seja visivel enquanto está a ser selecionado pelo random
    obstaculos.add(obstaculo);
    obstaculo.posicaoY = random(-30, -10);      //atribui um valor aleatorio no eixo do Y
    //obstaculo.escolherFaixa();                  //atribui uma faixa aleatoria
    obstaculo.posicaoX = random(width/3 + 20, width/2 + width/3/3 - 20);  //atribui posicao aleatoria no eixo do X com base na faixa escolhida
  }
  obstaculo.mostrar();
  obstaculo.mover(velocidade);
  if (obstaculo.posicaoY > height) {
    obstaculos.remove(obstaculo);         //obstaculo é removido quando atinge limite inferior da janela, volta para o topo
  }
}


//--------- PONTUAÇÃO NO ECRÃ
void apresentarPontuacao() {
  textSize(16);
  text("Pontuação: ", width/2 + 50, 20);
  textSize(40);
  text(pontos, width/2 + 50, 60);
}


//--------- CAMERA DO LADO ESQUERDO
void apresentarCamera() {
  if (camera.available()) {
    camera.read();
  }
  camera.loadPixels();
  textSize(15);
  shape(aviso, 10, height/2 - camera.height + 85, 18, 18);
  text("Está a ser filmado! ", 30, height/2 - camera.height + 100);

  rect(-3, height/2 - camera.height/2 - 3, camera.width + 6, camera.height + 6);
  scale(-1, 1); //inverter camera
  image(camera, 0, height/2 - camera.height/2, -camera.width, camera.height);
}


//------------ COLISAO ENTRE CARRO E OBSTACULO
boolean colisao(Obstaculo o) {
  if ((o.posicaoX > xCarro && o.posicaoX < xCarro + carro.width) || 
    (o.posicaoX + o.getObjetoWidth() < xCarro + carro.width) && o.posicaoX + o.getObjetoWidth() > xCarro) {
    if (o.posicaoY + o.getObjetoHeight() > yCarro) {
      return true;
    }
  }
  return false;
}



//------------- APARECER MENU INICIAL
void menu() {
  background(#FF7043);
  PShape icon;
  icon = loadShape("car-breakdown.svg");
  shape(icon, width/2 - icon.width/2 /2, height/2 - 270, icon.width/2, icon.height/2);

  textSize(15);
  text("(c) Pedro Mata Rodrigues", 110, height - 20);
  textSize(40);
  textAlign(CENTER);
  text("RoadRunner", width/2, height/2 + 50);
  textSize(20);
  text("Diga 'Jogar' para iniciar o jogo", width/2, height/2 + 100);
  gameOver = true;
  if (volume > limite) {
    gameOver = false;
    aJogar = true;
  }
}



//------------ MENU DE SELECAO DE CARRO
void selecionaCarro() {
  background(#66BB6A);

  textSize(40);
  text("Selecione o carro", width/2, 60);
  textSize(50);
  text("1", width/2 - tanque.width - 40, 150);
  text("2", width/2 + automovel.width - 70, 150);
  noStroke();

  tanque.resize(340, 350);
  image(tanque, width/2 - tanque.width - 40, 150);
  automovel.resize(180, 350);
  image(automovel, width/2 + automovel.width, 150); 

  //------------ Seleção do carro
  if (keyPressed) {
    if (key == '1') {
      carro = tanque;
    }
    if (key == '2') {
      carro = automovel;
    }
    if (key == ENTER) {
      carroEscolhido = true;
    }
  }
  if(carro == tanque){
      fill(#81C784);
      rect(width/2 - tanque.width - 40, 150, tanque.width, tanque.height);
      fill(#66BB6A);
      rect(width/2 + automovel.width - 70, 150, tanque.width, tanque.height);
      tanque.resize(340, 350);
      image(tanque, width/2 - tanque.width - 40, 150);
  }
  if(carro == automovel){
      fill(#81C784);  
      rect(width/2 + automovel.width - 70, 150, tanque.width, tanque.height);
      fill(#66BB6A);
      rect(width/2 - tanque.width - 40, 150, tanque.width, tanque.height);
      automovel.resize(180, 350);
      image(automovel, width/2 + automovel.width, 150); 
  }
  fill(255);
}
