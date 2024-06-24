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
            speed = SPEED[difficulty];
        }
    } else if (scene == 1) {
        if (canMove) {
            if (keyCode == UP) { // 上移動
                if (isStackEmpty(x, y - 1) && isStackEmpty(x + dx4[rot], y + dy4[rot] - 1)) {
                    y--;
                }
            }
            if (keyCode == DOWN) { // 下移動
                if (isStackEmpty(x, y + 1) && isStackEmpty(x + dx4[rot], y + dy4[rot] + 1)) {
                    y++;
                }
            }
            if (isTwo) {
                if (keyCode == LEFT) { // 反時計回り回転
                    int nextRot = (rot + 1) % 4;
                    if (isStackEmpty(x + dx4[nextRot], y + dy4[nextRot])) {
                        rot = nextRot;
                    }
                }
                if (keyCode == RIGHT) { // 時計回り回転
                    int nextRot = (rot + 3) % 4;
                    if (isStackEmpty(x + dx4[nextRot], y + dy4[nextRot])) {
                        rot = nextRot;
                    }
                }
            }
        }
    } else if (scene == 2) {
        if (timer > 10) {
            if (keyCode == LEFT || keyCode == RIGHT) { // 左右キー入力でゲーム開始画面へ
                initialize();
            }
        }
    }
    if (key == ' ') spaceKey = true;
}

void keyReleased() { // キーが離れたときの割込み
    if (key == ' ') {
        spaceKey = false;
    }
}
