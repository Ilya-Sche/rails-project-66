# README
[![Ruby on Rails CI](https://github.com/Ilya-Sche/rails-project-66/actions/workflows/ci.yml/badge.svg)](https://github.com/Ilya-Sche/rails-project-66/actions/workflows/ci.yml)

[![hexlet-check](https://github.com/Ilya-Sche/rails-project-66/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/Ilya-Sche/rails-project-66/actions/workflows/hexlet-check.yml)

Приложение доступно по ссылке - https://rails-65.onrender.com

# Рубокоп Проверка Репозитория

Это приложение предоставляет функциональность для интеграции с GitHub, подключает репозитории, выполняет проверку кода с помощью RuboCop и отправляет отчеты на электронную почту. Приложение автоматически выполняет проверку RuboCop при каждом пуше в репозиторий и отправляет отчет на указанный email.

## Как это работает

1. **Авторизация через GitHub**: Для начала работы необходимо войти в приложение через GitHub. Мы используем OAuth для получения доступа к репозиториям пользователя.
   
2. **Подключение репозитория**: После авторизации вы можете выбрать репозитории, к которым хотите подключиться. Приложение будет отслеживать изменения в этих репозиториях.

3. **Запуск проверки RuboCop**: Когда в подключенный репозиторий будет произведен push, приложение автоматически запускает RuboCop для проверки кода. Проверка включает в себя анализ кода на наличие стиля, ошибок и других проблем.

4. **Отправка отчета на email**: После выполнения проверки RuboCop, если обнаружены ошибки, отчет с результатами проверки будет отправлен на электронную почту пользователя.

