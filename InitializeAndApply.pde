void initialize() { // シーン1での値の初期化
    for (int i = 0; i < WIDTH; i++) for (int j = 0; j < HEIGHT; j++) {
        lcd[i][j] = ' ';
        stack[i][j] = 0;
        priority[i][j] = 0;
        nextPriority[i][j] = 0;
    }
    lcd[4][1] = 'N';
    lcd[5][1] = 'U';
    lcd[6][1] = 'M';
    lcd[7][1] = 'B';
    lcd[8][1] = 'E';
    lcd[9][1] = 'R';
    lcd[10][1] = ' ';
    lcd[11][1] = 'C';
    lcd[12][1] = 'O';
    lcd[13][1] = 'M';
    lcd[14][1] = 'B';
    lcd[15][1] = 'O';
    lcd[7][2] = '-';
    lcd[8][2] = 'E';
    lcd[9][2] = 'A';
    lcd[10][2] = 'S';
    lcd[11][2] = 'Y';
    lcd[12][2] = '-';
    lcd[8][3] = 'H';
    lcd[9][3] = 'A';
    lcd[10][3] = 'R';
    lcd[11][3] = 'D';
    speed = 2;
    x = WIDTHG - 2;
    y = 1;
    rot = 0;
    num = 1;
    num2 = 1;
    canMove = true;
    doFall = false;
    didSynth = false;
    maxNum = 1;
    timer = 0;
    score = 0;
    isTwo = false;
    scene = 0;
    difficulty = 0;
    combo = 0;
}

void apply() { // 自身と落ちた数字の盤面からlcdを書き換え
    for (int i = 0; i < WIDTH; i++) for (int j = 0; j < HEIGHT; j++) {
        if (stack[i][j] == 0) lcd[i][j] = ' ';
        else lcd[i][j] = char(stack[i][j] + 48); // 文字コード分だけ足す
    }
    if (canMove) {
        lcd[x][y] = char(num + 48);
        if (isTwo) lcd[x + dx4[rot]][y + dy4[rot]] = char(num2 + 48);
    }
}

void scene1Apply() {
    lcd[14][0] = '|';
    lcd[14][1] = '|';
    lcd[14][2] = '|';
    lcd[14][3] = '|';
    lcd[15][0] = 'S';
    lcd[16][0] = 'C';
    lcd[17][0] = 'O';
    lcd[18][0] = 'R';
    lcd[19][0] = 'E';
    lcd[16][1] = char(int(score / 1000) + 48);
    lcd[17][1] = char(int((score % 1000) / 100) + 48);
    lcd[18][1] = char(int((score % 100) / 10) + 48);
    lcd[19][1] = char(int(score % 10) + 48);
    lcd[15][2] = 'C';
    lcd[16][2] = 'O';
    lcd[17][2] = 'M';
    lcd[18][2] = 'B';
    lcd[19][2] = 'O';
    if (int(combo / 10) != 0) lcd[18][3] = char(int(combo / 10) + 48);
    lcd[19][3] = char(int(combo % 10) + 48);
}

void changeToScene2() { // シーン2への遷移
    for (int i = 0; i < WIDTH; i++) for (int j = 0; j < HEIGHT; j++) {
        lcd[i][j] = ' ';
    }
    lcd[7][0] = 'R';
    lcd[8][0] = 'E';
    lcd[9][0] = 'S';
    lcd[10][0] = 'U';
    lcd[11][0] = 'L';
    lcd[12][0] = 'T';
    if (difficulty == 0) {
        lcd[7][1] = '-';
        lcd[8][1] = 'E';
        lcd[9][1] = 'A';
        lcd[10][1] = 'S';
        lcd[11][1] = 'Y';
        lcd[12][1] = '-';
    }
    if (difficulty == 1) {
        lcd[7][1] = '-';
        lcd[8][1] = 'H';
        lcd[9][1] = 'A';
        lcd[10][1] = 'R';
        lcd[11][1] = 'D';
        lcd[12][1] = '-';
    }
    hiscore[difficulty] = max(score, hiscore[difficulty]);
    lcd[4][2] = 'S';
    lcd[5][2] = 'C';
    lcd[6][2] = 'O';
    lcd[7][2] = 'R';
    lcd[8][2] = 'E';
    lcd[9][2] = ' ';
    lcd[10][2] = ' ';
    lcd[11][2] = ':';
    lcd[12][2] = char(int(score / 1000) + 48);
    lcd[13][2] = char(int((score % 1000) / 100) + 48);
    lcd[14][2] = char(int((score % 100) / 10) + 48);
    lcd[15][2] = char(int(score % 10) + 48);
    lcd[4][3] = 'H';
    lcd[5][3] = 'I';
    lcd[6][3] = 'S';
    lcd[7][3] = 'C';
    lcd[8][3] = 'O';
    lcd[9][3] = 'R';
    lcd[10][3] = 'E';
    lcd[11][3] = ':';
    lcd[12][3] = char(int(hiscore[difficulty] / 1000) + 48);
    lcd[13][3] = char(int((hiscore[difficulty] % 1000) / 100) + 48);
    lcd[14][3] = char(int((hiscore[difficulty] % 100) / 10) + 48);
    lcd[15][3] = char(int(hiscore[difficulty] % 10) + 48);
}
