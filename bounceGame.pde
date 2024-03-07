int playerWidth = 60;
int playerHeight = 20;
float ballX, ballY;
float ballSpeed = 8;
int score = 0;
float ballSpeedX = 2; 
float ballSpeedY = 2;

// Variabler til spil settings:
int gameState = 0; // 0 = start menu, // 1 = i spillet, 2 = game over menu.
String[] difficultyLevels = {"Easy", "Medium", "Hard"};
int selectedDifficulty = 0;
int bestScoreSession = 0; // Gemmer den bedste score for denne session af spillet.

int countdownTime = 3; // Sekunder for nedtælling
boolean countdownStarted = false; // Markerer om nedtællingen er startet
long countdownStartTime;



//Håndtering af vores baggrund
PImage bgImage;


//Forskellige varibler til håndtering af efekter
boolean scoreDecreased = false;
int blinkTimer = 0;

// debug(dev mode)
boolean prints = true; // er der bare for at slå prints til og fra i console.


// Guld mønter
class GoldCoin {
  float x, y; // Position
  float vx, vy; // Hastighed
  boolean collected = false; // Om mønten er samlet op

  GoldCoin(float x, float y, float vx, float vy) {
    this.x = x;
    this.y = y;
    this.vx = vx; // Sætter hastigheden i x-retningen
    this.vy = vy; // Sætter hastigheden i y-retningen
  }

  void update() {
    if (!collected) {
      x += vx;
      y += vy;
      
      // Tjek for kollision med spillets kanter og "bounce" tilbage
      if (x <= 0 || x >= width) vx = -vx;
      if (y <= 0 || y >= height) vy = -vy;
    }
  }

  void display() {
    if (!collected) {
      fill(255, 215, 0); // Guldfarve
      ellipse(x, y, 20, 20); // Tegner mønten
    }
  }

  boolean hit(float ballX, float ballY) {
    if (collected) return false;
    float d = dist(x, y, ballX, ballY);
    if (d < 10 + 10) { // Antagelse: boldens radius + møntens radius
      collected = true;
      return true;
    }
    return false;
  }
} // Denne afsluttende krølleparentes var manglet, hvilket afslutter klassen

ArrayList<GoldCoin> coins = new ArrayList<GoldCoin>();

void initializeCoins() {
  coins.clear(); // Fjerner eksisterende mønter fra listen
  // Tilføj nye mønter med tilfældige positioner og hastigheder
  coins.add(new GoldCoin(random(50, width-50), random(50, height-50), random(-2, 2), random(-2, 2)));
  coins.add(new GoldCoin(random(50, width-50), random(50, height-50), random(-2, 2), random(-2, 2)));
  coins.add(new GoldCoin(random(50, width-50), random(50, height-50), random(-2, 2), random(-2, 2)));
  // Tilføj flere mønter efter behov
}




void setup() {
  size(500, 500);
  ballX = width / 2;
  ballY = 0;
  bgImage = loadImage("back.jpg");
  
  initializeCoins(); // Initialiser mønterne
}


void devModePrints(String text) {
  if (prints) {
     println(text);
  }
}


// Functions:
void showDifficultyMenu() {
  background(200);
  textAlign(CENTER);
  textSize(20);
  text("Select Difficulty", width / 2, height / 3);

  for (int i = 0; i < difficultyLevels.length; i++) {
    if (i == selectedDifficulty) {
      fill(255, 0, 0); // Fremhæver den valgte sværhedsgrad med en rød farve
    } else {
      fill(0);
    }
    text(difficultyLevels[i], width / 2, height / 2 + i * 30);
  }

  fill(0);
  textSize(15);
  text("Use the up and down arrow keys to select and press Enter to start", width / 2, height - 60);
}



void setDifficulty(int difficulty) {
  switch (difficulty) {
    case 0: // Let
      ballSpeedX = 4;
      ballSpeedY = 4;
      countdownStarted = true;
      break;
    case 1: // Mellem
      ballSpeedX = 6;
      ballSpeedY = 6;
      countdownStarted = true;
      break;
    case 2: // Svær
      ballSpeedX = 9;
      ballSpeedY = 9;
      countdownStarted = true;
      break;
  }
}


void keyPressed() {
  if (gameState == 0) { // Hvis vi er i menuen
    if (keyCode == UP) {
      selectedDifficulty = max(0, selectedDifficulty - 1);
    } else if (keyCode == DOWN) {
      devModePrints("Trykker ned af");
      selectedDifficulty = min(difficultyLevels.length - 1, selectedDifficulty + 1);
    } else if (keyCode == ENTER || keyCode == RETURN) {
      devModePrints("Trykker enter");
      setDifficulty(selectedDifficulty);
      gameState = 1; // Ændre vores state så spillet starter.
      startCountdown(); // Starter vores countdown
    }
  }
  if (gameState == 2 && key == 'r' || key == 'R') {
    gameState = 0; // Tilbage til startmenuen eller direkte til spilstart (gameState = 1)
    score = 0; // Nulstiller score
    // Nulstil yderligere spilvariabler her, f.eks. boldens position og hastighed
    ballX = width / 2;
    ballY = 0;
    initializeCoins(); // Geninitialiser mønterne for det nye spil
  }
}


void showGameOverScreen() {
  background(0); 
  fill(255); 
  textAlign(CENTER);
  textSize(32);
  text("Game Over :(", width / 2, height / 4);
  text("Best Score: " + bestScoreSession, width / 2, height / 3);
  textSize(20);
  text("This Round Score: " + score, width / 2, height / 2);
  textSize(16);
  text("Pres 'R' to reset the game", width / 2, height * 2/3);
  countdownStarted = false; // Nulstiller countdown
}

// Tegner vores "bouncer"
void drawTrampoline(float x, float y, float width, float height) {
  // Sæt farven til hvid for trampolinen
  stroke(255); 
  fill(255); 

  // Tegner trampolinens overflade
  rect(x, y, width, height);

  // Tegner benene på trampolinen
  float legHeight = height / 2;
  float legWidth = width * 0.1; // Benenes bredde som en procentdel af trampolinens bredde

  // Venstre ben
  line(x + legWidth, y + height, x + legWidth, y + height + legHeight);

  // Højre ben
  line(x + width - legWidth, y + height, x + width - legWidth, y + height + legHeight);
}


// Countdown så spillet ikke bare starter med det samme.
void startCountdown() {
  countdownStarted = true;
  countdownStartTime = millis(); // Gemmer det nuværende tidspunkt
}










void draw() {
  if (gameState == 0) {
    showDifficultyMenu();
  } else if (countdownStarted) {
    image(bgImage, 0, 0, width, height);
    int timeLeft = countdownTime - ((int)(millis() - countdownStartTime) / 1000);
    
    if (timeLeft > 0) {
      fill(255);
      textSize(48);
      textAlign(CENTER, CENTER);
      text(timeLeft, width / 2, height / 2);
    } else {
      countdownStarted = false;
      gameState = 1; // Sætte gameState så spillet starter
    }
    
  } else if (gameState == 1) {
    textSize(24);
    devModePrints("Spillet loader og starter");
    background(255);
    image(bgImage, 0, 0, width, height);
    
    // Beregn trampolinens position baseret på musens position
    float playerX = mouseX - playerWidth / 2;
    float trampolineY = height - playerHeight - 10; // Flytter den lidt op af så man bedere kan se vores trempolin.
  
    
    drawTrampoline(playerX, trampolineY, playerWidth, playerHeight);
    
    // Tegner bolden
    ellipse(ballX, ballY, 20, 20);
    
    // Opdaterer boldens position
    ballX += ballSpeedX;
    ballY += ballSpeedY;
    
    // Bouncer mod skærmens kanter
    if (ballX <= 0 || ballX >= width) {
      ballSpeedX *= -1;
    }
    if (ballY <= 0) {
      ballSpeedY *= -1;
    }
    
    // Når bolden bouncer mod vores "trampolin"
    if (ballY >= height - playerHeight - 10 && ballY < height - playerHeight && ballX >= playerX && ballX <= playerX + playerWidth) {
      ballSpeedY *= -1;
      score++; // Opdaterer scoren med en hver gang bolden rammes
    }
    
    // Giver brugeren gameover skærm, hvis bolden ikke rammes.
    if (ballY > height) {
      scoreDecreased = true;
      blinkTimer = 30; // Sæt timeren for rød blinkende effekt (valgfrit)
      gameState = 2; // Sætter vores game state til 2 = Game over menu
    }
    
    //Tjekker om bolden har ramt en mønt:
      for (GoldCoin coin : coins) {
        coin.update(); // Opdaterer møntens position
        coin.display(); // Tegner mønten
        
        // Tjek kun for ikke-samlede mønter
        if (!coin.collected && coin.hit(ballX, ballY)) {
          score += 5; // Øger scoren med 5
        }
      }

      
    // Viser nuværende score og effekt, hvis man mister et point
    if (scoreDecreased && blinkTimer > 0) {
      fill(255, 0, 0); 
      blinkTimer--; // Reducer timeren for hvert frame
    } else {
      fill(0);
      scoreDecreased = false; // Reset på vores variable
    }
    fill(255);
    text("Score: " + score, 35, 20);
  } else if (gameState == 2) {
    if (score > bestScoreSession) {
      bestScoreSession = score;
    }
    showGameOverScreen();
  }
}
