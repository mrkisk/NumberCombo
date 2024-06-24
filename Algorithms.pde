int getStack(int x, int y) { return (x >= 0 && x < WIDTHG && y >= 0 && y < HEIGHT) ? stack[x][y] : -1; }
boolean isStackEmpty(int x, int y) { return getStack(x, y) == 0; }

boolean canFall() { // 左隣にブロックがなければfalse、あればtrue
    return isStackEmpty(x - 1, y) && (!isTwo || isStackEmpty(x - 1 + dx4[rot], y + dy4[rot]));
}

void synth() { // 合成処理
    didSynth = false;
    int dx4Prirority[] = {-1, 0, 0, 1};
    int dy4Prirority[] = {0, -1, 1, 0};
    for (int k = 2; k > 0; k--) for (int j = 0; j < HEIGHT; j++) for (int i = 0; i < WIDTH; i++) {
        if (priority[i][j] == k) {
            // 隣接する同じ数字の中で最も優先度の高い物を合成する
            int maxPriority = -1;
            int dir = -1;
            for (int l = 0; l < 4; l++) {
                int nx = i + dx4Prirority[l];
                int ny = j + dy4Prirority[l];
                if (getStack(nx, ny) == stack[i][j] && priority[nx][ny] > maxPriority) {
                    dir = l;
                    maxPriority = priority[nx][ny];
                }
            }
            if (dir >= 0) { // 消すやつがあったとき
                didSynth = true;
                combo++;
                if (stack[i][j] == 9) { // 消すやつが9のとき
                    score += pow(2, stack[i][j]);
                    stack[i][j] = 0;
                    priority[i][j] = 0;
                    if (!doFall && stack[i + 1][j] > 0) doFall = true;
                } else { //消すやつが8以下のとき
                    score += stack[i][j] * combo;
                    stack[i][j]++;
                    priority[i][j] = -1;
                    nextPriority[i][j] = 2;
                    maxNum = max(stack[i][j], maxNum);
                    if (maxNum >= TWONUM) isTwo = true;
                    if (maxNum >= SPEEDUPNUM) speed = SPEED[difficulty] - 1;
                }
                // 数字を消し、落とすかを判定
                int nx = i + dx4Prirority[dir];
                int ny = j + dy4Prirority[dir];
                stack[nx][ny] = 0;
                priority[nx][ny] = 0;
                if (!doFall && stack[nx + 1][ny] > 0) {
                    doFall = true;
                }
            }
        }
    }
}

void updatePriority() { // 優先度の更新
    for (int i = 0; i < WIDTH; i++) {
        for (int j = 0; j < HEIGHT; j++) {
            priority[i][j] = nextPriority[i][j];
            nextPriority[i][j] = 0;
        }
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
                // 落とす数字の優先度を2ならば維持し、そうでなければ1にする
                if (priority[i][j] == 2) {
                    priority[i - countZero][j] = 2;
                    priority[i][j] = 0;
                } else priority[i - countZero][j] = 1;
            }
        }
    }
    doFall = false;
}

void initializeMove() { // 次の数字が落ち始める直前の初期化
    canMove = true;
    for (int i = 0; i < WIDTH; i++) {
        for (int j = 0; j < HEIGHT; j++) {
            priority[i][j] = 0;
            nextPriority[i][j] = 0;
        }
    }
    x = WIDTHG - 2;
    y = 1;
    rot = 0;
    changeNum();
    doFall = false;
    didSynth = false;
    // combo = 0;
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
