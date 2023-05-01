#!/bin/bash
# Получаем внешний IP-адрес
MYHOST_IP=$(hostname -I | cut -d' ' -f1)
# Обновление пакетов
printf "\e[42mОбновление пакетов системы...\e[0m\n"
apt update
printf "\e[42mПакеты успешно обновлены.\e[0m\n"

# Установка Git
printf "\e[42mУстановка Git...\e[0m\n"
apt install git -y
printf "\e[42mGit успешно установлен.\e[0m\n"

# Клонирование репозитория
printf "\e[42mКлонирование репозитория dwg...\e[0m\n"
git clone https://github.com/dignezzz/dwg.git temp

if [ ! -d "dwg" ]; then
  mkdir dwg
  echo "Папка DWG создана."
else
  echo "Папка DWG уже существует."
fi

# копирование содержимого временной директории в целевую директорию с перезаписью существующих файлов и папок
cp -rf temp/* dwg/

# удаление временной директории со всем ее содержимым
rm -rf temp
printf "\e[42mРепозиторий dwg успешно клонирован до актуальной версии из репозитория автора.\e[0m\n"

# Установка прав на директорию tools
printf "\e[42mУстановка прав на директорию DWG...\e[0m\n"
chmod +x -R dwg
printf "\e[42mПрава на директорию DWG успешно установлены.\e[0m\n"

# Переходим в папку DWG
printf "\e[42mПереходим в папку dwg...\e[0m\n"
cd dwg
printf "\e[42mПерешли в папку dwg\e[0m\n"

# Запуск скрипта ufw.sh
printf "\e[42mЗапуск скрипта docker.sh для установки Docker и Docker-compose...\e[0m\n"
./tools/ufw.sh
printf "\e[42mСкрипт docker.sh успешно выполнен.\e[0m\n"


# Устанавливаем редактор Nano
if ! command -v nano &> /dev/null
then
    read -p "Хотите установить текстовый редактор Nano? (y/n) " INSTALL_NANO
    if [ "$INSTALL_NANO" == "y" ]; then
        apt-get update
        apt-get install -y nano
    fi
else
    echo "Текстовый редактор Nano уже установлен."
fi




# Выводим в консоль сообщение с инструкциями для пользователя
printf "Выберите, что хотите установить:\n1. DWG-CLI\n2. DWG-UI\n"

# Считываем ввод пользователя и сохраняем его в переменную
read -r user_input

# Проверяем, что пользователь ввел 1 или 2
if [[ "$user_input" == "1" ]]; then
  # Проверяем, существует ли файл docker-compose.yml
  if [[ -f "docker-compose.yml" ]]; then
    # Если файл существует, предлагаем пользователю переименовать его
    printf "Файл docker-compose.yml уже существует. Хотите переименовать его в docker-compose.yml.old? (y/n)\n"
    read -r rename_response
    if [[ "$rename_response" == "y" ]]; then
      mv docker-compose.yml docker-compose.yml.old.$((100 + RANDOM % 2900))
    else
      exit 1
    fi
  fi
  # Переименовываем файл docker-compose.yml.CLI в docker-compose.yml
  mv docker-compose.yml.CLI docker-compose.yml
  printf "Файл docker-compose.yml.CLI успешно переименован в docker-compose.yml\n"
  #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### ####   #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### 
 #### ЗДЕСЬ КОД ДЛЯ УСТАНОВКИ DWG-CLI

 #### ЗДЕСЬ КОНЕЦ КОДА
  #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### ####   #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### 
elif [[ "$user_input" == "2" ]]; then
  # Проверяем, существует ли файл docker-compose.yml
  if [[ -f "docker-compose.yml" ]]; then
    # Если файл существует, предлагаем пользователю переименовать его
    printf "Файл docker-compose.yml уже существует. Хотите переименовать его в docker-compose.yml.old? (y/n)\n"
    read -r rename_response
    if [[ "$rename_response" == "y" ]]; then
      mv docker-compose.yml docker-compose.yml.old.$((100 + RANDOM % 2900))
    else
      exit 1
    fi
  fi
  # Переименовываем файл docker-compose.yml.UI в docker-compose.yml
  mv docker-compose.yml.UI docker-compose.yml
  printf "Файл docker-compose.yml.UI успешно переименован в docker-compose.yml\n"
  #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### ####   #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### 
 #### ЗДЕСЬ КОД ДЛЯ УСТАНОВКИ DWG-UI
# Проверяем есть ли контейнер с именем wireguard

printf "${BLUE} Сейчас проверим свободен ли порт 51821 и не установлен ли другой wireguard.\n${NC}"

if [[ $(docker ps -q --filter "name=wireguard") ]]; then
    printf "!!!!>>> Другой Wireguard контейнер уже запущен, и вероятно занимает порт 51821. Пожалуйста удалите его и запустите скрипт заново\n "
    printf "${RED} !!!!>>> Завершаю скрипт! \n${NC}"
    exit 1
else
    printf "Wireguard контейнер не запущен в докер. Можно продолжать\n"
    # Проверка, запущен ли контейнер, использующий порт 51821
    if lsof -Pi :51821 -sTCP:LISTEN -t >/dev/null ; then
        printf "${RED}!!!!>>> Порт 51821 уже используется контейнером.!\n ${NC}"
        if docker ps --format '{{.Names}} {{.Ports}}' | grep -q "wg-easy.*:51821->" ; then
            printf "WG-EASY контейнер использует порт 51821. Хотите продолжить установку? (y/n): "
            read -r choice
            case "$choice" in 
              y|Y ) printf "Продолжаем установку...\n" ;;
              n|N ) printf "${RED} ******* Завершаю скрипт!\n ${NC}" ; exit 1;;
              * ) printf "${RED}Некорректный ввод. Установка остановлена.${NC}" ; exit 1;;
            esac
        else
            printf "${RED} ******* Завершаю скрипт!\n ${NC}"
            exit 1
        fi
    else
        printf "Порт 51821 свободен.\n"
        printf "Хотите продолжить установку? (y/n): "
        read -r choice
        case "$choice" in 
          y|Y ) printf "Продолжаем установку...\n" ;;
          n|N ) printf "Установка остановлена.${NC}" ; exit 1;;
          * ) printf "${RED}Некорректный ввод. Установка остановлена.${NC}" ; exit 1;;
        esac
    fi
fi

printf "${GREEN} Этап проверки докера закончен, можно продолжить установку\n${NC}"

# Получаем внешний IP-адрес
MYHOST_IP=$(hostname -I | cut -d' ' -f1)

# Записываем IP-адрес в файл docker-compose.yml с меткой MYHOSTIP
sed -i -E  "s/- WG_HOST=.*/- WG_HOST=$MYHOST_IP/g" docker-compose.yml

# Запросите у пользователя пароль
echo ""
echo ""
#while true; do
#  read -p "Введите пароль для веб-интерфейса: " WEBPASSWORD
#  echo ""

# if [[ "$WEBPASSWORD" =~ ^[[:alnum:]]+$ ]]; then
#    # Записываем в файл новый пароль в кодировке UTF-8
#    sed -i -E "s/- PASSWORD=.*/- PASSWORD=$WEBPASSWORD/g" docker-compose.yml
#    break
#  else
#    echo "Пароль должен состоять только из английских букв и цифр, без пробелов и специальных символов."
#  fi
#done
echo -e "Введите пароль для веб-интерфейса (если пропустить, по умолчанию будет задан openode) "
read -p "Требования к паролю: Пароль может содержать только цифры и английские символы: " WEBPASSWORD || WEBPASSWORD="openode"
echo ""

if [[ "$WEBPASSWORD" =~ ^[[:alnum:]]+$ ]]; then
  # Записываем в файл новый пароль в кодировке UTF-8
  sed -i -E "s/- PASSWORD=.*/- PASSWORD=$WEBPASSWORD/g" docker-compose.yml
else
  echo "Пароль должен состоять только из английских букв и цифр, без пробелов и специальных символов."
fi


# Даем пользователю информацию по установке
# Читаем текущие значения из файла docker-compose.yml
CURRENT_PASSWORD=$(grep PASSWORD docker-compose.yml | cut -d= -f2)
CURRENT_WG_HOST=$(grep WG_HOST docker-compose.yml | cut -d= -f2)
CURRENT_WG_DEFAULT_ADDRESS=$(grep WG_DEFAULT_ADDRESS docker-compose.yml | cut -d= -f2)
CURRENT_WG_DEFAULT_DNS=$(grep WG_DEFAULT_DNS docker-compose.yml | cut -d= -f2)


# Выводим текущие значения
echo ""
echo -e "${BLUE}Текущие значения:${NC}"
echo ""
echo -e "Пароль от веб-интерфейса: ${BLUE}$CURRENT_PASSWORD${NC}"
echo -e "IP адрес сервера: ${BLUE}$CURRENT_WG_HOST${NC}"
echo -e "Маска пользовательских IP: ${BLUE}$CURRENT_WG_DEFAULT_ADDRESS${NC}"
echo -e "Адрес входа в веб-интерфейс WireGuard после установки: ${YELLOW}http://$CURRENT_WG_HOST:51821${NC}"
echo ""

 #### ЗДЕСЬ КОНЕЦ КОДА
  #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### ####   #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### 
else
  # Если пользователь ввел что-то кроме 1 или 2, выводим ошибку
  printf "Ошибка: некорректный ввод\n"
  exit 1
fi

# Запрашиваем у пользователя, хочет ли он поменять пароль для SSH
printf "Вы хотите поменять пароль для SSH? (y/n): "
read ssh_answer

# Если пользователь отвечает "y" или "Y", запускаем скрипт для изменения пароля
if [[ "$ssh_answer" == "y" || "$ssh_answer" == "Y" ]]; then
  # Запуск скрипта ssh.sh
  printf "\e[42mЗапуск скрипта ssh.sh для смены стандартного порта SSH...\e[0m\n"
  ./tools/ssh.sh
  printf "\e[42mСкрипт ssh.sh успешно выполнен.\e[0m\n"
fi

# Запрашиваем у пользователя, хочет ли он поменять пароль для SSH
printf "Вы хотите установить UFW Firewall? (y/n): "
read ufw_answer

# Если пользователь отвечает "y" или "Y", запускаем скрипт для изменения пароля
if [[ "$ufw_answer" == "y" || "$ufw_answer" == "Y" ]]; then
# Запуск скрипта ufw.sh
printf "\e[42mЗапуск скрипта ufw.sh для установки UFW Firewall...\e[0m\n"
./tools/ufw.sh
printf "\e[42mСкрипт ufw.sh успешно выполнен.\e[0m\n"

# Переходим в папку /
printf "\e[42mПереходим в папку /root/...\e[0m\n"
cd
printf "\e[42mПерешли в папку /root/ \e[0m\n"
