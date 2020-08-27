//Cell→Cell

//親や子への参照を保持して伝搬するようにする
class Cell{
  int degree;
  PVector position;
  int height;
  int width;
  int h_by_w_ratio;

  bool already_reproduced = false;

  Cell child;
  // 外見上のアスペクト比だけを変える

  Cell(int x,int y, int _width, int _h_by_w_ratio, int _degree){
    position = new PVector(x, y);
    width=_width;
    h_by_w_ratio = _h_by_w_ratio;
    height = width * h_by_w_ratio;
    degree=_degree;
  }

  void visualize(){
    fill(250, 0, 15);
    ellipse(position.x, position.y, height, width);
  }

  Cell[] update()
  {
    h_by_w_ratio += random(-0.05, 0.05);
    height = width*h_by_w_ratio;
    Cell[] children = reproduce();
    return children;
  }

//生殖時に他のにぶつかったらそいつを子として認識する
//そうすると、末尾が先頭を子として認識する丸パターン以外にも、突然ぶつかってきたやつに子として認識されるパターンが出てくる

  Cell[] reproduce(){// child のheight, widthが分からないと接触するようにつくれない
  // または始点を原点以外に
    if(already_reproduced) return [];
    already_reproduced = true;
    PVector child_x = position.x + width*0.6*cos(degree);
    PVector child_y = position.y + height*0.6*sin(degree);
    PVector child_width = random(10,50);
    PVector child_h_by_w_ratio = random(0.44,2.3);
    if(random(0,10)<1){
      child = new EyedCell(child_x, child_y, child_width, child_h_by_w_ratio, degree+ degrees(0.003));

    } else{
      child = new Cell(child_x, child_y, child_width, child_h_by_w_ratio, degree+ degrees(0.003));
    }
    return [child];
    // アスペクト比の変化に応じた子の場所の変化
    // 2つ以上との接触で生殖能力を失う →丸になったとき生殖がストップできる
    // 生みたい位置に既にあれば止まる→こっちのほうがいい、これでも自動修復できる
    // 円のパターンが安定になるようにする→壁にぶつかるとエネルギー不足で死亡。円にしないといつか壁にぶつかる
    // 子どもからエネルギーを吸い取る
    // 円になってしまえば生殖しないわけだがそのエネルギーはどこへ向かう
  }
}

class EyedCell extends Cell{ //EyedCellは真円に近いほうがいい
//TODO:目も楕円であるべき
  int white_eye_size;
  int white_eye_degree;
  int white_eye_position_x;
  int white_eye_position_y;
  int blue_eye_size;
  int blue_eye_degree;
  EyedCell(int x,int y, int _width, int _w_by_h_ratio, int degree){
    super(x, y, _width, _w_by_h_ratio, degree);

    height = random(40,50);
    width = random(40,50);

    white_eye_size = height/2;
    white_eye_degree = degrees(random(0,360));
    white_eye_position_x = position.x-((width/4)*cos(white_eye_degree));
    white_eye_position_y = position.y-((height/4)*sin(white_eye_degree));

    blue_eye_size = white_eye_size * 0.48;
    blue_eye_degree = degrees(random(0,360));
  }
  void visualize(){
    super.visualize();


    // white eye
    fill(255, 255, 255);
    ellipse(white_eye_position_x, white_eye_position_y, white_eye_size*0.8, white_eye_size*0.8);

    // blue eye
    fill(3, 104, 186);
    ellipse(white_eye_position_x + blue_eye_size/2*cos(blue_eye_degree),
            white_eye_position_y + blue_eye_size/2*sin(blue_eye_degree),
            blue_eye_size*0.7, blue_eye_size*0.7);
  }
}

Cell[] lifes = [];

void setup() {
  noStroke();
  size(1000, 1000);
  frameRate(20);
  lifes[0] = new EyedCell(340, 200, 40, 3/4, degrees(120));
}

void draw(){
  background(0xff);
  Cell[] new_lifes = [];
  for(int i; i!=lifes.length; i++){
    new_lifes = new_lifes.concat(lifes[i].update());
  }
  lifes = lifes.concat(new_lifes);
  for(int i; i!=lifes.length; i++){
    lifes[i].visualize();
  }
}
// 消すときも番号は保ったままにすれば番号=生物とできるのではないか
// 末尾のやつが消えてnullになっていることともともとnullなことを区別する必要が

void mousePressed(){
  PVector mPos = new PVector(mouseX, mouseY);
  lifes = lifes.filter(function(l){ return !(PVector.sub(mPos, l.position).mag() < l.height)});
}
