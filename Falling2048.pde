final int WIDTH = 20; // 横のマスの数
final int HEIGHT = 4; // 縦のマスの数
final int WIDTHG = 14; // ゲーム画面の横のマスの数
final int SPEEDEASY = 3;
final int SPEEDHARD = 2;

int[][] stack = new int[WIDTH][HEIGHT]; // 既に落ちている数字
char[][] lcd = new char[WIDTH][HEIGHT]; // lcdに出力する文字
int[][] priority = new int[WIDTH][HEIGHT]; // 合成した先の優先度
int[][] nextPriority = new int[WIDTH][HEIGHT]; // 優先度を更新するための記憶
int speed; // 何フレームおきに落ちるか
int x, y, rot, num, num2; // 自身のx座標、y座標、回転方向、数字
boolean canMove; // 自身を動かせるか
boolean doFall; // 落とす処理を行うかどうか
boolean didSynth; // 合成をしたかどうか
int maxNum; // 最大の数値-1
int timer; // タイマー
int score; // スコア
int th; // 2個に変わる閾値
boolean isTwo; // 2個かどうか
int scene; // 0でスタート画面、1でゲーム画面、2でスコア表示
int[] hiscore = {0, 0}; // ハイスコア、こいつだけ初期化しない
int difficulty; // 0はeasy、1はhard
boolean spacekey = false; // スペースキーが押されてるときにtrue、押されてないときにfalse
int combo;

void setup() {
    size(1100, 500);
    frameRate(10);
    initialize();
}

void clearLcd() { // lcdをまっさらに
    for (int i = 0; i < WIDTH; i++) for (int j = 0; j < HEIGHT; j++) {
        lcd[i][j] = ' ';
    }
}

void keyPressed() { // キーが押されたタイミングで割込み処理（描画なし）
    if (scene == 0) {
        if (keyCode == UP) { // 上を押すとeasyにカーソル移動
            difficulty = 0;
            lcd[7][2] = '-';
            lcd[12][2] = '-';
            lcd[7][3] = ' ';
            lcd[12][3] = ' ';
        }
        if (keyCode == DOWN) { // 下を押すとhardにカーソル移動
            difficulty = 1;
            lcd[7][2] = ' ';
            lcd[12][2] = ' ';
            lcd[7][3] = '-';
            lcd[12][3] = '-';
        }
        if (keyCode == LEFT || keyCode == RIGHT) { // 右か左を押すとゲーム開始
            scene = 1;
            //clearLcd();
            if (difficulty == 0) speed = speedEasy;
            if (difficulty == 1) speed = speedHard;
        }
    } else if (scene == 1) {
        if (canMove) {
            if (keyCode == UP) { // 上移動
                if (rot == 0 || rot == 3) {
                    if (y > 0 && stack[x][y - 1] == 0) y--;
                } else if (rot == 1) {
                    if (y > 1 && stack[x][y - 2] == 0) y--;
                } else if (rot == 2) {
                    if (y > 0 && stack[x - 1][y - 1] == 0) y--;
                }
            }
            if (keyCode == DOWN) { // 下移動
                if (rot == 0 || rot == 1) {
                    if (y < 3 && stack[x][y + 1] == 0) y++;
                } else if (rot == 2) {
                    if (y < 3 && stack[x - 1][y + 1] == 0) y++;
                } else if (rot == 3) {
                    if (y < 2 && stack[x][y + 2] == 0) y++;
                }
            }
            if (isTwo) {
                if (keyCode == LEFT) { // 反時計回り回転
                    if (rot == 0) {
                        if (y > 0 && stack[x][y - 1] == 0) rot = 1;
                    } else if (rot == 1) {
                        if (stack[x - 1][y] == 0) rot = 2;
                    } else if (rot == 2) {
                        if (y < 3 && stack[x][y + 1] == 0) rot = 3;
                    } else if (rot == 3) {
                        if (stack[x + 1][y] == 0) rot = 0;
                    }
                }
                if (keyCode == RIGHT) { // 時計回り回転
                    if (rot == 0) {
                        if (y < 3 && stack[x][y + 1] == 0) rot = 3;
                    } else if (rot == 1) {
                        if (stack[x + 1][y] == 0) rot = 0;
                    } else if (rot == 2) {
                        if (y > 0 && stack[x][y - 1] == 0) rot = 1;
                    } else if (rot == 3) {
                        if (stack[x - 1][y] == 0) rot = 2;
                    }
                }
            }
        }
    } else if (scene == 2) {
        if (timer > 10) if (keyCode == UP || keyCode == DOWN || keyCode == LEFT || keyCode == RIGHT) { // 上下左右入力でシーン0へ //変更点
            initialize();
        }
    }
    if (key == ' ') spacekey = true;
}

void keyReleased() { // キーが離れたときの割込み
    if (key == ' ') spacekey = false;
}

void draw() { // 0.1秒おき
    if (scene == 0) {
        drawing();
    } else if (scene == 1) {
        timer++;
        if (spacekey && canMove) { // 落とすスピードを上げる
            while (canFall()) x--;
            timer = int(timer / speed) * speed;
        }
        if (timer % speed == 0) {
            if (canMove) { // 動けるときの処理
                if (canFall()) { // 落とす
                    x--;
                } else { // 確定する
                    canMove = false;
                    combo = 0; //変更点
                    stack[x][y] = num;
                    priority[x][y] = 2; // 吸収されるように落ちたやつ自身の優先度を上げる
                    if (isTwo) {
                        doFall = true; // 2個の場合は先に落とす
                        if (rot == 0) {
                            stack[x + 1][y] = num2;
                            priority[x + 1][y] = 2;
                        } else if (rot == 1) {
                            stack[x][y - 1] = num2;
                            priority[x][y - 1] = 2;
                        } else if (rot == 2) {
                            stack[x - 1][y] = num2;
                            priority[x - 1][y] = 2;
                        } else {
                            stack[x][y + 1] = num2;
                            priority[x][y + 1] = 2;
                        }
                    }
                }
            } else { // 吸収したり落としたりする処理
                if (!doFall) { // 落とさないなら
                    synth();
                    updatePriority();
                    if (!didSynth) { // 合成が無かったら
                        initialMove();
                        // println("Score : " + score);
                        if (stack[WIDTHG - 2][1] != 0) { //変更点
                            scene = 2;
                            timer = 0; //変更点
                        }
                    }
                } else { // 落とすなら
                    fall();
                }
            }
        }
        apply();
        scene1Apply(); //変更点
        drawing();
    } else if (scene == 2) {
        timer++; //変更点
        changeToScene2();
        drawing();
    }
}

boolean canFall() { // 左隣にブロックがなければfalse、あればtrue
    if (!isTwo) {
        return x > 0 && stack[x - 1][y] == 0;
    } else {
        if (rot == 0) return x > 0 && stack[x - 1][y] == 0;
        else if (rot == 1) return x > 0 && stack[x - 1][y] == 0 && stack[x - 1][y - 1] == 0;
        else if (rot == 2) return x - 1 > 0 && stack[x - 2][y] == 0;
        else return x > 0 && stack[x - 1][y] == 0 && stack[x - 1][y + 1] == 0;
    }
}

void synth() { // 合成処理
    didSynth = false;
    for (int k = 2; k > 0; k--) for (int j = 0; j < HEIGHT; j++) for (int i = 0; i < WIDTH; i++) {
        if (priority[i][j] == k) {
            // 隣接する同じ数字の中で最も優先度の高い物を合成する
            int maxP = -1;
            int dir = 0;
            if (i > 0 && stack[i - 1][j] == stack[i][j]) {
                maxP = priority[i - 1][j];
            }
            if (j > 0 && stack[i][j - 1] == stack[i][j] && priority[i][j - 1] > maxP) {
                dir = 1;
                maxP = priority[i][j - 1];
            }
            if (j < HEIGHT - 1 && stack[i][j + 1] == stack[i][j] && priority[i][j + 1] > maxP) {
                dir = 2;
                maxP = priority[i][j + 1];
            }
            if (i < WIDTH - 1 && stack[i + 1][j] == stack[i][j] && priority[i + 1][j] > maxP) {
                dir = 3;
                maxP = priority[i + 1][j];
            }
            if (maxP >= 0) { // 消すやつがあったとき
                didSynth = true;
                combo++;
                if (stack[i][j] == 7) speed = 2 - difficulty; //変更点
                if (stack[i][j] == 9) { // 消すやつが9のとき
                    // speed = 2 - difficulty; // speedを変える //変更点
                    score += pow(2, stack[i][j]);
                    stack[i][j] = 0;
                    priority[i][j] = 0;
                    if (!doFall && stack[i + 1][j] != 0) doFall = true;
                } else { //消すやつが8以下のとき
                    score += stack[i][j] * combo; //変更点
                    maxNum = max(stack[i][j], maxNum);
                    if (maxNum >= th - 1) isTwo = true;
                    stack[i][j]++;
                    priority[i][j] = -1;
                    nextPriority[i][j] = 2;
                }
                if (dir == 0) {
                    stack[i - 1][j] = 0;
                    doFall = true;
                    priority[i - 1][j] = 0;
                } else if (dir == 1) {
                    stack[i][j - 1] = 0;
                    if (!doFall && stack[i + 1][j - 1] != 0) doFall = true;
                    priority[i][j - 1] = 0;
                } else if (dir == 2) {
                    stack[i][j + 1] = 0;
                    if (!doFall && stack[i + 1][j + 1] != 0) doFall = true;
                    priority[i][j + 1] = 0;
                } else if (dir == 3) {
                    stack[i + 1][j] = 0;
                    if (!doFall && stack[i + 2][j] != 0) doFall = true;
                    priority[i + 1][j] = 0;
                }
            }
        }
    }
}

void updatePriority() { // 優先度の更新
    for (int i = 0; i < WIDTH; i++) for (int j = 0; j < HEIGHT; j++) {
        priority[i][j] = nextPriority[i][j];
        nextPriority[i][j] = 0;
    }
}

void fall() { // 落とす処理
    int countZero;
    for (int j = 0; j < HEIGHT; j++) {
        countZero = 0;
        for (int i = 0; i < WIDTH; i++) {
            if (stack[i][j] == 0) countZero++;
            else if (countZero != 0) {
                stack[i - countZero][j] = stack[i][j];
                stack[i][j] = 0;
                if (priority[i][j] == 2) {
                    priority[i - countZero][j] = 2;
                    priority[i][j] = 0;
                } else priority[i - countZero][j] = 1;
            }
        }
    }
    doFall = false;
}

void printPriority() {
    for (int j = 0; j < HEIGHT; j++) {
        for (int i = 0; i < WIDTH; i++) {
            print(priority[i][j] + " ");
        }
        println();
    }
    println();
}

void initialMove() { // 次の数字が落ち始める直前の初期化
    canMove = true;
    for (int i = 0; i < WIDTH; i++) for (int j = 0; j < HEIGHT; j++) {
        priority[i][j] = 0;
        nextPriority[i][j] = 0;
    }
    x = WIDTHG - 2; //変更点
    y = 1;
    rot = 0;
    changeNum();
    doFall = false;
    didSynth = false;
    // combo = 0; //変更点
}

void changeNum() { // 落ちる数字の乱数調整
    int sum = 0;
    if (isTwo) maxNum--;
    for (int i = 1; i <= maxNum; i++) sum += pow(2, i);
    float rand = random(sum);
    for (int i = maxNum; i > 0; i--) {
        if (rand < pow(2, i)) {
            num = maxNum + 1 - i;
            break;
        }
        rand -= pow(2, i);
    }
    if (isTwo) {
        maxNum++;
        num++;
        num2 = int(random(1, num));
    }
}

void apply() { // 自身と落ちた数字の盤面からlcdを書き換え
    for (int i = 0; i < WIDTH; i++) for (int j = 0; j < HEIGHT; j++) {
        if (stack[i][j] == 0) lcd[i][j] = ' ';
        else lcd[i][j] = char(stack[i][j] + 48); // 文字コード分だけ足す
    }
    if (canMove) {
        lcd[x][y] = char(num + 48);
        if (isTwo) {
            if (rot == 0) lcd[x + 1][y] = char(num2 + 48);
            else if (rot == 1) lcd[x][y - 1] = char(num2 + 48);
            else if (rot == 2) lcd[x - 1][y] = char(num2 + 48);
            else if (rot == 3) lcd[x][y + 1] = char(num2 + 48);
        }
    }
}

void scene1Apply() { //変更点
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

void drawing() { // lcdの描画
    // if (combo != 0) lcd[19][3] = char(combo + 48); //変更点
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
    x = WIDTHG - 2; //変更点
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
    th = 5;
    isTwo = false;
    scene = 0;
    combo = 0;
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
