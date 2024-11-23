# terraformで遊ぼう
このリポジトリは、terraformに触れたときの備忘録として残しているものです。
内容的にはterraformでインスタンスを3台立て、ansibleを用いてk3sクラスタを立てるものです。

自分のサーバーに合わせ、LXDの設定などを行っています。 自分の環境に合うように修正して使ってみてください。

## 環境（私の場合）
- LXD
ストレージにceph(microceph)を活用。 ネットワークはovn(microovn)にて仮想化してます。

- ansible
terraformで作ったサーバーに設定を流し込むため、ansibleを使っています。

その他わからないことがございましたら、issueに投げていただければ解決できるんじゃないかなと...(;^ω^)

## ハマりそうなポイントメモ
### 変数名がよくわかんない
- 変数名ですが、resourceの場合は`{`の前に指定した文字列二つを`.`でつなげればいいです。resouce <リソース名> <変数名> {}となっていて、`リソース名.変数名`となっています。尚、リソース名は「プロバイダー」によって提供されるものです。クラスのように、メンバーが定義されているので、それに当てはめていけばよいのです。  
- variableはterraformコマンド使用時に聞かれる一種の外部変数です。　外部変数は様々な方法で定義できますが、一番良いのは`.tfvars`というファイルに`<key> = <value>\n...`で記述することです。記述した.tfvarsファイルは、`terraform (plan|apply|destroy) -var-file <.tfvars>`で指定できます。その他のコマンドは変数を使用しない為、不要です。variableは、variable <変数名> {}となっていて、`variable.変数名`となっています。  
- resourceのみ、「resource.~」を省略できますが、確か`resource.リソース名.変数名`という形でも行けたと思います。  

### listとcount
- terraformにはリストがあります。　これを使うことで、複数のインスタンスを作成するときなどに便利になります。 そもそも、resourceなど、そのまま定義したらオブジェクトという形になります。
- resouceにcountという変数をつけると、リストの中にオブジェクト`list(object)`という形式になります。
- listはそこら辺の言語と同様、`[]`を使った方法や、`element()`関数を使い、要素を取り出すことができるほか、`for`関数を用いても中身を取り出すことが可能です。
