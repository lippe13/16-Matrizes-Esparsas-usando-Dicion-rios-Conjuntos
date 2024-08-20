import java.util.HashSet;

Grafo grafo;

void setup() {
  size(800, 800);
  grafo = new Grafo(10);
}

void draw() {
  background(255);
  grafo.atualizar();
  grafo.desenhar();
}

class Grafo {
  int numVertices;
  int[][] matrizAdj;
  PVector[] posicoes;
  PVector[] velocidades;
  float raio = 20;
  float k = 0.001;
  float c = 3000;
  HashSet<PVector> arestas;
  int[] cores;

  Grafo(int numVertices) {
    this.numVertices = numVertices;
    matrizAdj = new int[numVertices][numVertices];
    posicoes = new PVector[numVertices];
    velocidades = new PVector[numVertices];
    cores = new int[numVertices];
    arestas = new HashSet<PVector>();
    inicializarPosicoes();
    gerarArestasAleatorias();
    colorirGrafo();
  }

  void gerarArestasAleatorias() {
    int numArestas = int(random(numVertices, numVertices * (numVertices - 1) / 2));
    for (int i = 0; i < numArestas; i++) {
      int v1 = int(random(0, numVertices));
      int v2 = int(random(0, numVertices));
      if (v1 != v2 && !arestas.contains(new PVector(v1, v2)) && !arestas.contains(new PVector(v2, v1))) {
        adicionarAresta(v1, v2);
        arestas.add(new PVector(v1, v2));
      }
    }
  }

  void adicionarAresta(int i, int j) {
    matrizAdj[i][j] = 1;
    matrizAdj[j][i] = 1;
  }

  void inicializarPosicoes() {
    float angulo = TWO_PI / (numVertices - 1);
    float raioCirculo = min(width, height) / 3;
    for (int i = 1; i < numVertices; i++) {
      float x = width / 2 + raioCirculo * cos((i - 1) * angulo);
      float y = height / 2 + raioCirculo * sin((i - 1) * angulo);
      posicoes[i] = new PVector(x, y);
      velocidades[i] = new PVector(0, 0);
    }
    posicoes[0] = new PVector(width / 2, height / 2);
    velocidades[0] = new PVector(0, 0);
  }

  void colorirGrafo() {
    boolean[] coresDisponiveis = new boolean[numVertices];
    for (int i = 0; i < numVertices; i++) coresDisponiveis[i] = true;
    for (int v = 0; v < numVertices; v++) {
      for (int u = 0; u < numVertices; u++) {
        if (matrizAdj[v][u] == 1 && cores[u] != 0) {
          coresDisponiveis[cores[u] - 1] = false;
        }
      }
      for (int cor = 1; cor <= numVertices; cor++) {
        if (coresDisponiveis[cor - 1]) {
          cores[v] = cor;
          break;
        }
      }
      for (int i = 0; i < numVertices; i++) coresDisponiveis[i] = true;
    }
  }

  void atualizar() {
    for (int i = 1; i < numVertices; i++) {
      PVector forca = new PVector(0, 0);
      for (int j = 0; j < numVertices; j++) {
        if (i != j) {
          PVector direcao = PVector.sub(posicoes[i], posicoes[j]);
          float distancia = direcao.mag();
          if (distancia > 0) {
            direcao.normalize();
            float forcaRepulsao = c / (distancia * distancia);
            direcao.mult(forcaRepulsao);
            forca.add(direcao);
          }
        }
      }
      for (int j = 0; j < numVertices; j++) {
        if (matrizAdj[i][j] > 0) {
          PVector direcao = PVector.sub(posicoes[j], posicoes[i]);
          float distancia = direcao.mag();
          direcao.normalize();
          float forcaAtracao = k * (distancia - raio);
          direcao.mult(forcaAtracao);
          forca.add(direcao);
        }
      }
      velocidades[i].add(forca);
      posicoes[i].add(velocidades[i]);
      velocidades[i].mult(0.5);
      if (posicoes[i].x < 0 || posicoes[i].x > width) velocidades[i].x *= -1;
      if (posicoes[i].y < 0 || posicoes[i].y > height) velocidades[i].y *= -1;
    }
  }

  void desenhar() {
    textAlign(CENTER);
    stroke(0);
    strokeWeight(1);
    for (PVector aresta : arestas) {
      int i = (int)aresta.x;
      int j = (int)aresta.y;
      line(posicoes[i].x, posicoes[i].y, posicoes[j].x, posicoes[j].y);
    }
    for (int i = 0; i < numVertices; i++) {
      fill(color(cores[i] * 50, 200, 150));
      ellipse(posicoes[i].x, posicoes[i].y, raio * 2, raio * 2);
      fill(0);
      text(str(i), posicoes[i].x, posicoes[i].y + 4);
    }
  }
}
