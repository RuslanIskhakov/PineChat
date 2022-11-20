# WalkieTalkie

Приложение для общения в чате с серверной частью, запускаемой на iPhone.

![pc copy](https://user-images.githubusercontent.com/4405543/202902193-db9ad0d2-5a08-45f7-a829-9293aa233a1b.PNG)

## Развертывание

- Клонировать проект: `https://github.com/RuslanIskhakov/PineChat`
- Настроить зависимости проекта: `pod install`
- Открыть файл `PineChat.xcworkspace` в X code

## Советы по использованию
- Для работы приложения требуется сеть Wi-Fi
- Если в качестве сети Wi-Fi используется Personal Hotspot, IP-адрес iPhone, на котором включена Personal Hotspot, будет иметь последний четвертый октет равный 1: `xxx.xxx.xxx.1`

## Технологический стек
- Swift
- CocoaPods
- UIKit
- WebSockets (server/client)
- RxSwift
- MVVM
- Core Data
