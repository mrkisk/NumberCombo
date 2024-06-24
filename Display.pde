void display() { // lcdの描画
    background(255);
    strokeWeight(2);
    for (int i = 0; i <= WIDTH; i++) line(50 + 50 * i, 50, 50 + 50 * i, 450);
    for (int i = 0; i <= HEIGHT; i++) line(50, 50 + 100 * i, 1050, 50 + 100 * i);
    textAlign(CENTER, CENTER);
    textSize(60);
    fill(0);
    for (int i = 0; i < WIDTH; i++)
        for (int j = 0; j < HEIGHT; j++)
            text(lcd[i][j], 75 + 50 * i, 90 + 100 * j);
}
