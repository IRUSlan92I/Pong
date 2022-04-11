-----КОНСТАНТЫ-----
local screenWidth = 1024            --ширина окна
local screenHeight = 768            --высота окна
local defaultBallSpeed = 500        --скорость мяча по умолчанию
local ballSpeedIncreaseWall = 10    --увеличение скорости при ударе об стену
local ballSpeedIncreasePad = 20     --увеличение скорости при ударе о пад
local ballSpeedRedusePad = 20       --уменьшение скорости при ударе о пад
local defaultBallAngle = 61         --угол шара по умолчанию
local ballAngleIncreasePad = 5      --увеличение угла при ударе о пад
local ballAngleRedusePad = 5        --уменьшение угла при ударе о пад

-----ЗАГРУЗКА ИГРЫ-----
function love.load()
    
    --Размер Окна--
    love.graphics.setMode(screenWidth, screenHeight, false, false, 1)
    
    --Пад 1--
    pad1 = {}
    pad1.width = 15                             --ширина
    pad1.height = 200                           --высота
    pad1.speed = 1000                           --скорость
    pad1.x = 11                                 --координата по X
    pad1.y = 384 - pad1.height / 2              --координата по Y
    pad1.score = 0                              --очки игрока
    
    --Пад 2--
    pad2 = {}
    pad2.width = 15                             --ширина
    pad2.height = 200                           --высота
    pad2.speed = 1000                           --скорость
    pad2.x = screenWidth - 11 - pad2.width      --координата по X
    pad2.y = 384 - pad2.height / 2              --координата по Y
    pad2.score = 0                              --очки игрока
    
    --Мяч--
    ball = {}
    ball.width = 20                             --ширина
    ball.height = 20                            --высота
    ball.speed = defaultBallSpeed               --скорость
    ball.x = screenWidth / 2 + ball.width / 2   --координата по X
    ball.y = screenHeight / 2                   --кордината по Y
    ball.angle = defaultBallAngle               --угол
    ball.direction = 0                          --направление
    
    winner = 0                                  --победитель

end

-----ОБНОВЛЕНИЕ ИГРЫ-----
function love.update(dt)
    
    --Пад 1--
    if love.keyboard.isDown("w") then                       --передвижение влево
        if (pad1.y > 7) then                                --проверка на касание границы
            pad1.y = pad1.y - pad1.speed * dt
        end
    elseif love.keyboard.isDown("s") then                   --передвижение вправо
        if (pad1.y < screenHeight - 7 - pad1.height) then   --проверка на касание границы
            pad1.y = pad1.y + pad1.speed * dt
        end
    end
    
    --Пад 2--
    if love.keyboard.isDown("up") then                      --передвижение влево
        if (pad2.y > 7) then                                --проверка на касание границы
            pad2.y = pad2.y - pad2.speed * dt
        end
    elseif love.keyboard.isDown("down") then                --передвижение вправо
        if (pad2.y < screenHeight - 7 - pad2.height) then   --проверка на касание границы
            pad2.y = pad2.y + pad2.speed * dt
        end
    end
    
    --Запуск Мяча--
    if (love.keyboard.isDown(" ")) and (ball.direction == 0) then   --проверка движется ли мяч
        if winner == 1 or winner == 2 then  --проверка закончена ли игра?
            winner = 0                      --если да
            pad1.score = 0                  --то сброс
            pad2.score = 0
        end
        ball.angle = defaultBallAngle       --сброс угла мяча
        ball.speed = defaultBallSpeed       --сброс скорости мяча
        ball.direction = math.random(4)     --задача случайного направления
    end
    

    --Передвижение Мяча--
    if ball.direction == 1 then
        ball.x = ball.x + (math.cos( ball.angle * (math.pi/180.0) ) * ball.speed * dt)
        ball.y = ball.y - (math.sin( ball.angle * (math.pi/180.0) ) * ball.speed * dt)
    elseif ball.direction == 2 then
        ball.x = ball.x - (math.cos( ball.angle * (math.pi/180.0) ) * ball.speed * dt)
        ball.y = ball.y - (math.sin( ball.angle * (math.pi/180.0) ) * ball.speed * dt)
    elseif ball.direction == 3 then
        ball.x = ball.x - (math.cos( ball.angle * (math.pi/180.0) ) * ball.speed * dt)
        ball.y = ball.y + (math.sin( ball.angle * (math.pi/180.0) ) * ball.speed * dt)
    elseif ball.direction == 4 then
        ball.x = ball.x + (math.cos( ball.angle * (math.pi/180.0) ) * ball.speed * dt)
        ball.y = ball.y + (math.sin( ball.angle * (math.pi/180.0) ) * ball.speed * dt)
    end
    
    --Управление Мячом--
    if love.keyboard.isDown("o") then
        ball.direction = 1
    elseif love.keyboard.isDown("i") then
        ball.direction = 2
    elseif love.keyboard.isDown("k") then
        ball.direction = 3
    elseif love.keyboard.isDown("l") then
        ball.direction = 4
    end
    
    --Отражение Мяча от Стенок--
    if ball.y < 6 then                                  --проверка на касание потолка
        ball.speed = ball.speed + ballSpeedIncreaseWall
        if ball.direction == 1 then                     --отражение
            ball.direction = 4
        elseif ball.direction == 2 then
            ball.direction = 3
        end
    elseif ball.y > screenHeight - ball.height - 6 then --проверка на касание пола
        ball.speed = ball.speed + ballSpeedIncreaseWall
        if ball.direction == 3 then                     --отражение
            ball.direction = 2
        elseif ball.direction == 4 then
            ball.direction = 1
        end
    end
    
    --Подсчет Очков и Сброс, Отражение от Падов Шара--
    if ball.x < pad1.x + pad1.width then                                --проверка на уход за границу
        if (ball.y < pad1.y) or (ball.y > pad1.y + pad1.height) then    --проверка на нахождение в зоне пада
        --если мяч вылетел:
            pad2.score = pad2.score + 1         --добавляем очко
            ball.x = screenWidth / 2            --сбрасываем
            ball.y = screenHeight / 2           --позицию мяча
            ball.direction = 0                  --и направление
        else
        --если же ударился о пад - отражаем:
            if ball.direction == 3 then
                ball.direction = 4
                --меняем угол и скорость мяча в зависимости от направления движения пада
                if love.keyboard.isDown("s") then
                    if (ball.angle < 90 - ballAngleIncreasePad) then
                        ball.speed = ball.speed + ballSpeedIncreasePad
                        ball.angle = ball.angle + ballAngleIncreasePad
                    end
                elseif love.keyboard.isDown("w") then
                    if (ball.angle > 0 + ballAngleRedusePad) then
                        ball.speed = ball.speed - ballSpeedRedusePad
                        ball.angle = ball.angle - ballAngleRedusePad
                    end
                end
            elseif ball.direction == 2 then
                ball.direction = 1
                --меняем угол и скорость мяча в зависимости от направления движения пада
                if love.keyboard.isDown("w") then
                    if (ball.angle < 90 - ballAngleIncreasePad) then
                        ball.speed = ball.speed + ballSpeedIncreasePad
                        ball.angle = ball.angle + ballAngleIncreasePad
                    end
                elseif love.keyboard.isDown("s") then
                    if (ball.angle > 0 + ballAngleRedusePad) then
                        ball.speed = ball.speed - ballSpeedRedusePad
                        ball.angle = ball.angle - ballAngleRedusePad
                    end
                end
            end
        end
    end
    
    if ball.x > pad2.x - ball.width then                                --проверка на уход за границу
        if (ball.y < pad2.y) or (ball.y > pad2.y + pad2.height) then    --проверка на нахождение в зоне пада
        --если мяч вылетел:
            pad1.score = pad1.score + 1         --добавляем очко
            ball.x = screenWidth / 2            --сбрасываем
            ball.y = screenHeight / 2           --позицию мяча
            ball.direction = 0                  --и направление
        else
        --если же ударился о пад - отражаем:
            if ball.direction == 1 then
                ball.direction = 2
                --меняем угол и скорость мяча в зависимости от направления движения пада
                if love.keyboard.isDown("up") then
                    if (ball.angle < 90 - ballAngleIncreasePad) then
                        ball.speed = ball.speed + ballSpeedIncreasePad
                        ball.angle = ball.angle + ballAngleIncreasePad
                    end
                elseif love.keyboard.isDown("down") then
                    if (ball.angle > 0 + ballAngleRedusePad) then
                        ball.speed = ball.speed - ballSpeedRedusePad
                        ball.angle = ball.angle - ballAngleRedusePad
                    end
                end
            elseif ball.direction == 4 then
                ball.direction = 3
                --меняем угол и скорость мяча в зависимости от направления движения пада
                if love.keyboard.isDown("down") then
                    if (ball.angle < 90 - ballAngleIncreasePad) then
                        ball.speed = ball.speed + ballSpeedIncreasePad
                        ball.angle = ball.angle + ballAngleIncreasePad
                    end
                elseif love.keyboard.isDown("up") then
                    if (ball.angle > 0 + ballAngleRedusePad) then
                        ball.speed = ball.speed - ballSpeedRedusePad
                        ball.angle = ball.angle - ballAngleRedusePad
                    end
                end

            end
        end
    end
    
    --Победа!--
    if pad1.score == 9 then
        winner = 1
        ball.direction = 0
    elseif pad2.score == 9 then
        winner = 2
        ball.direction = 0
    end
    

end

-----ОТРИСОВКА ИГРЫ-----
function love.draw()
    
    --Границы--
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.rectangle("fill", 0, 0, screenWidth, 5)
    love.graphics.rectangle("fill", 0, screenHeight - 5, screenWidth, 5)

    --Пад 1--
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.rectangle("fill", pad1.x, pad1.y, pad1.width, pad1.height)
    
    --Пад 2--
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.rectangle("fill", pad2.x, pad2.y, pad2.width, pad2.height)
    
    --Мяч--
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.rectangle("fill", ball.x, ball.y, ball.width, ball.height)
    
    --Счет--
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print(pad1.score, screenWidth/2 - 50, 10, 0, 5, 5, 1, 1)
    love.graphics.print("-", screenWidth/2+7, 10, 0, 5, 5, 1, 1)
    love.graphics.print(pad2.score, screenWidth/2 + 50, 10, 0, 5, 5, 1, 1)
    
    --Победа--
    if winner == 1 then
        love.graphics.print("Player 1 - Winner!", screenWidth/2-250, 100, 0, 5, 5, 1, 1)
    elseif winner == 2 then
        love.graphics.print("Player 2 - Winner!", screenWidth/2-250, 100, 0, 5, 5, 1, 1)
    end

end
