// import 文を使って foo.js の関数 greet1 をインポート
import { greet1 } from './foo.js';
// import 文を使って bar.js の関数 greet2 をインポート
import { greet2 } from './bar.js';
 
function component() {
  //div 要素を生成
  const divElem = document.createElement('div');
  //p 要素を生成
  const p1 = document.createElement('p');
  //インポートした greet1 の実行結果を p 要素のテキストに
  p1.textContent = greet1();
  //div 要素に上記 p 要素を追加
  divElem.appendChild(p1);
  const p2 = document.createElement('p');
  p2.textContent = greet2();
  divElem.appendChild(p2);
 
  return divElem;
}
 
document.body.appendChild(component());