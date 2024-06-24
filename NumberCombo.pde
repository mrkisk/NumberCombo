final int WIDTH = 20; // 横のマスの数
final int HEIGHT = 4; // 縦のマスの数
final int WIDTHG = 14; // ゲーム画面の横のマスの数
final int SPEED[] = {3, 2}; // 落ちるスピード
final int SPEEDUPNUM = 8; // この数値以上の数値ができるとスピードが速くなる
final int TWONUM = 5; // この数値以上の数値ができると2個になる

final int dx4[] = {1, 0, -1, 0};
final int dy4[] = {0, -1, 0, 1};

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
boolean isTwo; // 2個かどうか
int scene; // 0でスタート画面、1でゲーム画面、2でスコア表示
int[] hiscore = {0, 0}; // ハイスコア、こいつだけ初期化しない
int difficulty; // 0はeasy、1はhard
boolean spaceKey = false; // スペースキーが押されてるときにtrue、押されてないときにfalse
int combo;

void setup() {
    size(1100, 500);
    frameRate(10);
    initialize();
}

void draw() { // 0.1秒おき
    if (scene == 0) {
    } else if (scene == 1) {
        timer++;
        if (spaceKey && canMove) { // 落とすスピードを上げる
            while (canFall()) x--;
            timer = int(timer / speed) * speed;
        }
        if (timer % speed == 0) {
            if (canMove) { // 動けるときの処理
                if (canFall()) { // 落とす
                    x--;
                } else { // 確定する
                    canMove = false;
                    combo = 0;
                    stack[x][y] = num;
                    priority[x][y] = 2; // 吸収されるように落ちた数字の優先度を上げる
                    if (isTwo) {
                        doFall = true; // 2個の場合は先に落とす
                        stack[x + dx4[rot]][y + dy4[rot]] = num2;
                        priority[x + dx4[rot]][y + dy4[rot]] = 2;
                    }
                }
            } else { // 吸収したり落としたりする処理
                if (!doFall) { // 落とさないなら
                    synth();
                    updatePriority();
                    if (!didSynth) { // 合成が無かったら
                        initializeMove();
                        // println("Score : " + score);
                        if (stack[WIDTHG - 2][1] > 0) { // ゲームオーバー判定
                            scene = 2;
                            timer = 0;
                        }
                    }
                } else { // 落とすなら
                    fall();
                }
            }
        }
        apply();
        scene1Apply();
    } else if (scene == 2) {
        timer++;
        changeToScene2();
    }
    display();
}
