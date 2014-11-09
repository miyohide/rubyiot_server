rubyiot_server
==============
このソフトウェアは、住宅に設置されたセンサーの情報を収集したり、
機器を操作したりする、いわゆるIoTのサーバーを、
Rubyで実装したサンプルです。
開発にあたって、ECHONETの規格を少し意識しています。

全体像
------
このソフトウェアは、IoTをRubyで実装したサンプルの一部で、
全体は下記のような構成になっています。

    [device] - [gateway] - [server] - [mobile]
      ├ [sensor]
      └ [controller]

* device  
環境を測定する専用機器や、家電そのもの、家電のリモコンなどを想定しています。
デバイスに接続、もしくは内蔵されたsensorの測定値をgatewayに送信したり、
gatewayから送られてきた操作の命令に従って、各種機器のOn/Offなど、
controllerを制御します。
* gateway  
住宅ごとに1台から数台設置する、deviceとインターネットを接続する装置を
想定しています。
deviceから送られてきた情報を蓄積およびserverに送信したり、
mobileやserverから送られてきた操作の命令を、deviceに転送したりします。
* server  
たくさんのgatewayから送られてきた情報を蓄積して、
複数のgatewayに渡る情報をユーザーに提供したり、
mobileから送られてきた操作の命令を、適切なgatewayに転送したりします。
* mobile  
スマートフォンなどから、住宅の環境を確認したり、家電などを操作します。

serverの機能
------------
### Web画面
Web画面は現在ログイン画面のみで、他の機能と連携していません。

### API
以下のWeb APIを提供します。

* POST /api/device  
  * 機能: sensorやcontrollerが接続されたdeviceを、登録・更新する。
  * アクセス: gateway => server
  * POSTデータ: 以下のJSON形式のデータ  
  （propertiesのkeyはproperty_code。
  各codeはECHONET機器オブジェクト詳細規定による。）

            { "hardware_uid": "<Seriarl、MACなど>"
              "class_group_code": "0x00",
              "class_code": "0x00",
              "properties":
              { "0x00": "< sensor | controller >",

                ...

              }
            }

  * 応答データ: 以下のJSON形式のデータ  
  （1階層目のkeyはserverで発行するdevice_id。
  2階層目のkeyはproperty_code。
  valueはserverで発行するsensor_idまたはcontroller_id。）

            { "xxx":
              { "0x00": "yyy",

                ...

              }
            }

* POST /api/sensor  
  * 機能: sensorの名前を登録・更新する。
  * アクセス: mobile => server
  * POSTデータ: 以下のJSON形式のデータ
  （keyの"xxx"はserverで管理するsensor_id）

            { "xxx": { "name": "センサーの名前" } }

* GET /api/sensor?gateway_id=xxx  
  * 機能: 指定したgatewayの配下にあるsensorのリストを取得する。
  * アクセス: mobile => server
  * クエリ: gateway_id
  * GETデータ: 以下のJSON形式のデータ  
  （1階層目のkeyの"yyy"、"zzz"は、serverで管理するsensor_id）
  （2階層目のdevice_idは、serverで管理するdevice_id）

            { "yyy":
              { "name": "ex: キッチンのガス漏れセンサー",
                "property_name": "Detection threshold level",
                "device_id": "YYY",
                "value": "最新の測定値",
                "unit": "測定値の単位",
                "datetime": "最新の測定時刻",
                "alert": "< 0:無 | 1:有 >" },

              ...

              "zzz":
              { "name": "ex: リビングの温度計"
                "data-unit": "degree Celsius",
                "property_name": "Measured temperature value",
                "device_id": "ZZZ",
                "value": "最新の測定値",
                "datetime": "最新の測定時刻",
                "alert": "< 0:無 | 1:有 >" },

              ...

            }

* POST /api/controller  
  * 機能: controllerの名前を登録・更新する。
  * アクセス: mobile => server
  * POSTデータ: 以下のJSON形式のデータ
  （keyの"xxx"はserverで管理するcontroller_id）

            { "xxx": { "name": "機器と操作の内容" } }

* GET /api/controller?gateway_id=xxx  
  * 機能: 指定したgatewayの配下にあるsensorのリストを取得する。
  * アクセス: mobile => server
  * クエリ: gateway_id
  * GETデータ: 以下のJSON形式のデータ  
  （1階層目のkeyの"yyy"は、serverで管理するcontroller_id）  
  （2階層目のvalue_rangeは、"min","max"による値の範囲か、操作内容と値の列挙）
  （2階層目のdevice_idは、serverで管理するdevice_id）

            { "yyy":
              { "name": "ex: リビングのエアコンの電源",
                "property_name": "Operation status",
                "value_range": { "ON": "0", "OFF": "1" },
                "value": "1"
                "device_id": "YYY"}
              ...

            }

* POST /api/monitor  
  * 機能: sensorの監視値（上限値・下限値）を登録・更新する。
  * アクセス: mobile, gateway => server
  * POSTデータ: 以下の形式のJSONデータ  
  （1階層目のkeyの"xxx"はserverで管理するsensor_id）

            { "xxx": { "min": "下限値", "max": "上限値" } }

* GET /api/monitor?sensor_id=xxx  
  * 機能: sensorの監視値（上限値・下限値）を取得する。
  * アクセス: mobile, gateway => server
  * クエリ: sensor_id
  * GETデータ: 以下のJSON形式のデータ

            { "min": "下限値", "max": "上限値" }

* POST /api/sensor_data
  * 機能: センサーの測定データを登録する。
  * アクセス: gateway => server
  * POSTデータ: 以下の形式のJSONデータ
  （keyの"xxx"はserverで管理するsensor_id）

            { "xxx": "測定値" }

* GET /api/sensor_data?sensor_id=xxx&start=2014-10-10+12:00:00&span=daily  
  * 機能: serverに蓄積されたセンサーの測定データを取得する。
  * アクセス: mobile => server
  * クエリ: sensor_id, start（取得する時刻範囲の開始時刻）,  
    span（5-minutely, hourly, daily, weekly, monthly, yearlyのいずれか。
    5-minutely, hourlyはstartが48時間以上前の場合は指定できない。）
  * GETデータ: 以下のJSON形式のデータ
  （測定時刻の間隔は下表のようにspanによって調整し、件数が概ね200件以下になるようにする）

            { "測定時刻": "測定値", "測定時刻": "測定値", ... }

  | span       | 間隔  | 件数  |
  |------------|-------|------|
  | 5-minutely |   3秒 |  100 |
  | hourly     |  30秒 |  120 |
  | daily(※)  |  10分 |  144 |
  | weekly     | 1時間 |  168 |
  | monthly    | 6時間 |  124 |
  | yearly     |   1日 |  366 |
  ※dailyは、48時間以上前の場合、1時間間隔24件となる。

* GET /api/sensor_alert?sensor_id=xxx&datetime=2014-10-10+12:00:00  
  * 機能: 現在もしくは指定した時刻の測定値が、異常値であったかを取得する。
  * アクセス: mobile => server
  * クエリ: sensor_id, datetime（指定しない場合は現在時刻）
  * GETデータ: 以下のJSON形式のデータ

            { "alert": "< 0:無 | 1:有 >", "value": "測定値",
              "datetime": "測定時刻", "min": "下限値", "max": "上限値" }

* POST /api/operation  
  * 機能: controllerへの操作指示を登録する。
  * アクセス: mobile => server
  * POSTデータ: 以下のJSON形式のデータ
  （keyの"xxx"はserverで管理するcontroller_id）  
  （操作値はECHONET機器オブジェクト詳細規定による。今回は ON/OFF の 0/1 のみ。）

            { "xxx": "操作値" }

  * 応答データ: 以下のJSON形式のデータ  

            { "operation_id": "xxx" }

* GET /api/operation?gateway_id=xxx  
  * 機能: controllerへの操作指示を取得する。（1リクエストにつき1操作）
  * アクセス: gateway => server
  * クエリ: gateway_id
  * GETデータ: 以下のJSON形式のデータ  
  （keyの"xxx"はserverで管理するcontroller_id）  
  （操作値はECHONET機器オブジェクト詳細規定による。今回は、0:ON, 1:OFFのみ。）

            { "xxx": { "operation_id": "yyy", "value": "操作値" } }

* POST /api/operation_status  
  * 機能: controllerへの操作指示を登録する。
  * アクセス: gateway => server
  * POSTデータ: 以下のJSON形式のデータ
  （keyの"xxx"はserverで管理するoperation_id、
  実行結果は、0:成功, 1:失敗）

            { "xxx": "実行結果" }

* GET /api/operation_status?operation_id=xxx  
  * 機能: controllerへの操作指示の内容と状態を取得する。
  * アクセス: mobile => server
  * クエリ: operation_id
  * GETデータ: 以下のJSON形式のデータ  
  （状態値は、0:未実行, 1:実行中, 2:完了, 9:異常）

            { "value": "操作値", "status": "状態値" }


使用方法
--------
### 動作環境
最低限、以下のソフトウェアがインストールされている必要があります。
* Ruby 2.1.3
* SQLite 3（開発環境）
* MySQL 5.5（本番環境）

### データベースの用意
本番環境では、MySQLのデータベースを以下のように用意します。
なお、ここではlocalhostにデータベースを用意していますが、異なるホストに用意する場合は、
適宜内容を変更してください。

    mysql> CREATE DATABASE rubyiot_server DEFAULT CHARACTER SET 'utf8';
    mysql> GRANT ALL PRIVILEGES ON rubyiot_server.* TO 'rubyiot'@'localhost' IDENTIFIED BY 'secret'

### デプロイ
本番環境の場合、アプリケーションを導入するディレクトリで、以下のようにコマンドを実行します。

    $ git clone https://github.com/ossforumjp-app-IoT/rubyiot_server.git
    $ cd rubyiot_server
    $ mkdir log
    $ mkdir tmp
    $ bundle install --path vendor/bundle
    $ export RAILS_ENV=production
    $ bundle exec rake db:migrate
    $ bundle exec unicorn -c unicorn.rb -E production -D

### ダミーデータ作成
下記スクリプトのSensorID、START、INTERVAL、SPANを編集して、以下のように実行します。

    $ export RAILS_ENV=production
    $ bundle exec ruby create_dummydata.rb


ライセンス
----------
Copyright(C) 2014 Japan OSS Promotion Forum

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
