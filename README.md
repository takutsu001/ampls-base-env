## ampls-base-env

## はじめに
本 Bicep は [AMPLS 検証環境用](https://zenn.dev/takutsu/articles/zenn-ampls-instruction) のベース環境を作成するBicepです。AMPLSの検証をしてみたいけど１から環境を作るのはめんどくさいなーと思う方にでも利用していただけますと幸いです（Bicepの勉強を兼ねて作成しています。初Bicepなのでべた書きですがご容赦ください）

> [!WARNING]
> 本環境は HUB の踏み台サーバーを経由して Spoke の VM にアクセスするような構成です。NSG で RDP(3389) への接続を許可するルールを作成していますが、セキュリティリスクが高いため、あくまでも検証用途としてご利用ください（本来は Azure Bastion や Azure Firewall を利用して踏み台サーバーへアクセスさせるべきですが、費用を下げるため NSG で穴あけを行っています）

## 構成図
![](/images/ampls-base-topology.png)

### 前提条件
ローカルPCでBicepを実行する場合は Azure CLI と Bicep CLI のインストールが必要となります。私はVS Code (Visual Studio Code) を利用してBicepファイルを作成しているのですが、結構使いやすいのでおススメです。以下リンクに VS Code、Azure CLI、Bicep CLI のインストール手順が纏まっています

https://learn.microsoft.com/ja-jp/azure/azure-resource-manager/bicep/install

## 使い方
本リポジトリーをローカルPCにクローンし、パラメータファイル (main.prod.bicepparam) を修正してご利用ください

**main.prod.bicepparam**
![](/images/bicepparam.png)

> [!IMPORTANT]
> NSGルール作成用の ***myipaddress*** の修正は必須となります。それ以外のパラメータの修正は任意で実施してください。Azureに接続するクライアントのパブリックIPアドレスが分からない場合は[こちらのサイト](https://www.cman.jp/network/support/go_access.cgi)で確認することができます

※Git を利用できる環境ではない場合はファイルをダウンロードしていただくでも問題ないと思います。その場合は、以下の構成でローカルPCにファイルを設置してください

```
main.bicep
main.prod.bicepparam
∟ modules/
　　∟ hubEnv.bicep
　　∟ spoke1Env.bicep 
```

## 実行手順 (Git bash)

1. Azureへのログインと利用するサブスクリプションの指定
```
az login
az account set --subscription <利用するサブスクリプション名>
```
> [!NOTE]
> az login を実行するとWebブラウザが起動するので、ログインを行う

2. ディレクトリの移動（main.bicep を設置したディレクトリへ移動）
```
cd <main.bicepを設置したディレクトリ>
```

3. デプロイの実行
```
az deployment sub create --location japaneast -f main.bicep -p main.prod.bicepparam
```

4. Azureからのログアウト
```
az logout
```