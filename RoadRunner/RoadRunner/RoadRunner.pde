import ddf.minim.*;
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
AudioPlayer musica, erro, inicio, motorLigar;

float volume;
float limite;
Minim minim;

float jitter;
float ang;

float velocidade;
float posicaoLinha;
float z;
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
PImage capacete;
PShape premio;
PShape oculos;
PShape volante;

// ------- Informações de Jogo
int pontos = 2;
boolean gameOver;
String[] topPontos = new String[5]; 
String username = "";

//---- Tracejado
Traco[] tracejado = new Traco[200];
Relva[] relvado = new Relva[200];
Estrada estrada = new Estrada();
ArrayList<Obstaculo> obstaculos = new ArrayList<Obstaculo>();

//---- Cara
Rectangle[] faces;

Obstaculo obstaculo = new Obstaculo();
Traco traco = new Traco();

//--------------------------------------------------------------------------- SETUP -----------------------------------------------
void setup() {
  noCursor();

  inputAudio = new AudioIn(this, 0);
  inputAudio.start();
  amplitude = new Amplitude(this);
  amplitude.input(inputAudio);

  // ------------- Janela
  z = random(0, 10);
  size(1200, 600);

  // ------------- Definir Camera
  camera = new Capture(this, 320, 240);
  //camera.start();
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
  //-------------Cabeça
  capacete = loadImage("capacete.png");
  oculos = loadShape("oculos.svg");
  //-------------Premio
  premio = loadShape("premio.svg");

  volante = loadShape("volante.svg");
  carregarSons();
  textAlign(CENTER);
}
//---------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------- DRAW -----------------------------------------------
void draw() { 
  //Analisar o volume e definir o limite
  volume = amplitude.analyze();
  limite = 0.4;
  if (!aJogar) {      //----------------------------------------------------------------MENU INICIAL
    fill(255);
    menu();    //------------ apresenta a pagina de inicio
  } else
    if (!carroEscolhido) {      //------------------------------------------------------MENU DE ESCOLHA DE CARRO
      motorLigar.play();
      musica.play();
      camera.start();
      selecionaCarro();
    } else {
      if (!gameOver) {                      //------------------------------------------INICIO DO JOGO
        motorLigar.pause();
        inicio.play();
        username = "";
        carregarAmbiente();
        //----------- Atribuir valor de velocidade
        velocidade += 0.5 ; //aumentar velocidade gradualmente
        pontos += 1;
        apresentarCamera();   // ------------------- carregar camera
        //-----------------------------------Detetar Cara
        opencv = new OpenCV(this, camera);
        opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
        faces = opencv.detect();
        //--------------------------------
        scale(-1, 1); //--- voltar a inverter camera
        noFill();
        stroke(0, 255, 0);
        strokeWeight(3);
        carregarCarro(); // ------------------------ carregar carro
        // -------- Pontos
        apresentarPontuacao();
        //-------------------------------------------- Em caso de colisão entre o obstaculo e o carro
        for ( int c = 0; c < obstaculos.size(); c++) {
          Obstaculo obstaculo = obstaculos.get(c);
          if (colisao(obstaculo)) {
            gameOver = true;
          }
        }
        if (keyPressed) {    //-------------- caso prima o ESPAÇO
          if (key == ' ') {
            automovel = loadImage("mercedes.png");
            tanque = loadImage("tanque.png");
            pontos = 0;
            velocidade = map(z, 0, 20, 1, 20);
            carroEscolhido = false;
          }
        }
      } else {
        //------------------------------------------------------------------------------ ECRA DE GAMEOVER
        ecraGameOver();      
        //--------------------------------------------------------------------------------------------- RECEBER O USERNAME
        receberUsername();
        //----------------------------------------------------------------------------------------------------------------
      }
    }
}



//-------------------------------------------------------- CARREGAR AMBIENTE-------------------------------------------------------------------
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
    obstaculo.posicaoX = random(width/3 + obstaculo.getObjetoWidth()/2, width/2 + width/3/3 - obstaculo.getObjetoWidth()/2);
    //obstaculo.posicaoX = random(width/3 + 20, width/2 + width/3/3 - 20);  //atribui posicao aleatoria no eixo do X com base na faixa
  }
  obstaculo.mostrar();
  obstaculo.mover(velocidade);
  if (obstaculo.posicaoY > height) {
    obstaculos.remove(obstaculo);         //obstaculo é removido quando atinge limite inferior da janela, volta para o topo
  }
}
//-----------------------------------------------------------------------------------------------------------------------------------

//------------------------------------------------------------ PONTUAÇÃO NO ECRÃ -------------------------------------------------------------
void apresentarPontuacao() {
  fill(255);
  textSize(16);
  text("Pontuação: ", width/2 + 50, 20);
  textSize(40);
  text(pontos, width/2 + 50, 60);

  fill(#43A047);
  noStroke();
  rect(width/2 - 500, 50, 200, 55, 10);
  textAlign(CENTER);
  fill(255);
  textSize(15);
  text("Prima SPACE para voltar \na selecionar o carro", width/2 - 400, 70);

  //-------------------------------TOP ---------------
  String[] dados; 
  if (loadStrings("topPontos.txt") == null) {
    dados = new String[5];
  } else {
    try {
      dados = loadStrings("topPontos.txt");
      topPontos = dados;
      topPontos = reverse(sort(dados, 5));
    }
    catch(Exception ex) {
      println("Erro ao carregar ficheiros!");
    }
  }

  textSize(50);
  text("TOP", width/2 + 400, 150);
  shape(premio, width/2 + 500, 100, 50, 50);
  int y = 200;
  textSize(20);
  textAlign(LEFT);
  for (int i = 0; i < topPontos.length; i++) {
    text(i+1 + "." + topPontos[i], width/2 + 300, y);
    y += 40;
  }
  textAlign(CENTER);
}
//--------------------------------------------------------------------------------------------------------------------------------

//------------------------------------------------------------- GUARDAR PONTOS -----------------------------------------------------------
void guardarPontos(int pontos, String username) {
  //topPontos = append(topPontos, String.valueOf(pontos));
  topPontos = reverse(sort(topPontos));
  topPontos = append(topPontos, pontos + "pts de " + username);
  saveStrings("topPontos.txt", topPontos);
}
//---------------------------------------------------------------------------------------------------------------------------------------------


//---------------------------------------------------------------- CAMERA DO LADO ESQUERDO --------------------------------------------------------
void apresentarCamera() {
  if (camera.available()) {
    camera.read();
  }

  camera.loadPixels();

  rect(-3, height/2 - camera.height/2 - 3, camera.width + 6, camera.height + 6);
  scale(-1, 1); //inverter camera
  image(camera, 0, height/2 - camera.height/2, -camera.width, camera.height);
}
//------------------------------------------------------------------------------------------------------------------------------------------


//---------------------------------------------------- COLISAO ENTRE CARRO E OBSTACULO --------------------------------------------------
boolean colisao(Obstaculo o) {
  if ((o.posicaoX > xCarro && o.posicaoX < xCarro + carro.width) || 
    (o.posicaoX + o.getObjetoWidth() < xCarro + carro.width) && o.posicaoX + o.getObjetoWidth() > xCarro) {
    if (o.posicaoY + o.getObjetoHeight() > yCarro) {
      return true;
    }
  }
  return false;
}
//--------------------------------------------------------------------------------------------------------------------------------------


//------------------------------------------------------------------- MENU INICIAL -----------------------------------------------------------------------
void menu() {
  background(#FF7043);
  PShape icon;  
  PImage logos;
  icon = loadShape("racer.svg");
  logos = loadImage("logosIPVCESTG.png");
  logos.resize(150, 60);

  pushMatrix();
  fill(#FF7043);
  strokeWeight(50);
  stroke(#FF8A65);
  rect(width/2 - icon.width/2, 100, icon.width, icon.height - 130);
  popMatrix();

  fill(255);
  shape(icon, width/2 - icon.width/2 /2, height/2 - 270, icon.width/2, icon.height/2);
  imageMode(CENTER);
  image(logos, width - (logos.width/2 + 10), height - (logos.height/2 + 20));
  imageMode(CORNER);

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
//--------------------------------------------------------------------------------------------------------------------------------------


//----------------------------------------------------------- MENU DE SELECAO DE CARRO -----------------------------------------------
void selecionaCarro() {
  background(#66BB6A);
  textSize(40);
  text("Selecione o carro", width/2, 60);
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
  if (carro == tanque) {
    fill(#66BB6A);
    strokeWeight(50);
    stroke(#81C784);
    rect(width/2 - (tanque.width + 60), 135, tanque.width + 40, tanque.height + 15);
    //fill(#66BB6A);
    //rect(width/2 + automovel.width - 70, 150, tanque.width, tanque.height);
    fill(#66BB6A);
    noStroke();
    rect(0, 0, width, 90);
    textSize(30);
    fill(255);
    text("Prima ENTER para confirmar", width/2, 60);
    tanque.resize(340, 350);
    image(tanque, width/2 - tanque.width - 40, 150);
  }
  if (carro == automovel) {
    fill(#66BB6A);
    strokeWeight(50);
    stroke(#81C784);    
    rect(width/2 + 85, 135, tanque.width, tanque.height + 15);
    //fill(#66BB6A);
    //rect(width/2 - tanque.width - 40, 150, tanque.width, tanque.height);
    noStroke();
    textSize(30);
    fill(#66BB6A);
    rect(0, 0, width, 90);
    fill(255);
    text("Prima ENTER para confirmar", width/2, 60);
    automovel.resize(180, 350);
    image(automovel, width/2 + automovel.width, 150);
  }


  textSize(50);
  text("1", width/2 - tanque.width - 40, 150);
  text("2", width/2 + automovel.width - 70, 150);
  fill(255);
}
//---------------------------------------------------------------------------------------------------------------------------------------------


//---------------------------------------------------------- CARREGAR SONS ----------------------------------------------------------
void carregarSons() {
  minim = new Minim(this);
  musica = minim.loadFile("we_walk_alone.mp3");
  erro = minim.loadFile("erro.mp3");
  inicio = minim.loadFile("inicio.mp3");
  motorLigar = minim.loadFile("motor_ligar.mp3");
}
//--------------------------------------------------------------------------------------------------------------------


//-------------------------------------------------------------------------ECRA DE GAME OVER
void ecraGameOver() {
  camera.stop();
  erro.play();      //SOM DE ERRO
  musica.pause();    //PARA A MUSICA
  noStroke();
  fill(#FF7043);
  //fill(#66BB6A);
  rect(width/2 - 400, height/2 - 200, 800, 400);
  //----------------------------------------
  fill(255);
  textSize(100);
  text("GAME OVER", width/2, height/2 - 50);
  textSize(40);
  text("Pontuação: " + pontos, width/2, height/2 + 60);
}



//-------------------------------------------------------------------------CARREGAR OS CARROS
void carregarCarro() {
  //--------- Carregar Carro
  for (int b = 0; b < faces.length; b++) {
    if (carro == tanque) {
      carro.resize(80, 85);
    }
    if (carro == automovel) {
      carro.resize(70, 140);
    }
    xCarro = -faces[0].x + 675;
    yCarro = faces[0].y + 400;
    image(carro, xCarro, yCarro, carro.width, carro.height); //carro
    image(capacete, -faces[0].x + 190, faces[0].y + 135, faces[0].width + 45, faces[0].height + 70); //capacete

    pushMatrix();
    if (xCarro > width/2) {
      jitter = 0.2;
    }
    if (xCarro < width/2) {
      jitter = -0.2;
    }
    shapeMode(CENTER);
    ang += jitter;
    float c = cos(ang);
    translate(150, height/2 + 175);
    rotate(c);
    shape(volante, 0, 0, 150, 150); //volante
    popMatrix();
  }
}


//------------------------------------------------------- INPUT DE USERNAME
void receberUsername() {
  if (keyPressed) {
    if (keyCode == BACKSPACE) {                                               //ELIMINA UMA LETRA
      if (username.length() > 0) {
        username = username.substring(0, username.length()-1);
      }
    } else if (keyCode == DELETE) {                                           //ELIMINA TUDO
      username = "";
    } else if (keyCode != SHIFT && keyCode != CONTROL && keyCode != ALT) {    //TECLAS DE SHIFT, CTRL E ALT NÃO FAZEM NADA
      username = username + key;                                              //RESTANTES TECLAS ADICIONAM AO TEXTO
    }
    if (key == ENTER) {
      guardarPontos(pontos, username);
      carroEscolhido = false;
      automovel = loadImage("mercedes.png");
      tanque = loadImage("tanque.png");
      gameOver = false;
      obstaculo.posicaoY = -2;
      pontos = 0;
      velocidade = map(z, 0, 20, 1, 20);
    }
  }
  text("Introduza o seu username:", width/2, height/2 + 100);
  textSize(25);
  text(username, width/2, height/2 + 140);                                   //texto do username no ecra
}
