local Locale = Class('Locale')

function Locale:initialize()
    self.filename = 'lang'

    self.langs = {
        en = {
            main_menu = {
                ai = 'Play with AI',
                player = 'Play with another player',
                controls = 'Controls',
                language = 'Change language',
                credits = 'Credits',
                quit = 'Quit',
            },
            credits = {
                code = 'Code & sounds',
                art = 'Art',
                music = 'Music',
            },

            controls = {
                player1 = 'Player1',
                cast1 = 'Spell casting',
                cast1value = 'WASD',
                attack1 = 'Attack',
                attack1value = 'Left ctrl or left shift',

                effect = 'Toggle effect: F3',
                fullscreen = 'Toggle fullscreen: F11',

                player2 = 'Player 2',
                cast2 = 'Spell casting',
                cast2value = 'Arrows',
                attack2 = 'Attack',
                attack2value = 'Right ctrl or right shift',
            },

            dead_heat = 'Dead heat!',
            paused = 'Paused',
            win_title = 'Player %d wins!',
            elapsed_time_title = 'Elapsed time is %d seconds.',
            pause_info = 'Press space to enter to the main menu.',
            win_info = 'Press space to start over.',
        },
        ru = {
            main_menu = {
                ai = 'Играть с ботом',
                player = 'Друг против друга',
                controls = 'Управление',
                language = 'Сменить язык',
                credits = 'Авторы',
                quit = 'Выход',
            },
            credits = {
                code = 'Код и звуки',
                art = 'Спрайты и изображения',
                music = 'Музыка',
            },

            controls = {
                player1 = 'Игрок 1',
                cast1 = 'Создание заклинания',
                cast1value = 'WASD',
                attack1 = 'Атака',
                attack1value = 'Левый ctrl или левый shift',

                effect = 'Переключить эффект: F3',
                fullscreen = 'Полноэкранный режим: F11',

                player2 = 'Игрок 2',
                cast2 = 'Создание заклинания',
                cast2value = 'Стрелки',
                attack2 = 'Атака',
                attack2value = 'Правый ctrl или правый shift',
            },

            dead_heat = 'Ничья!',
            paused = 'Пауза',
            win_title = 'Игрок %d одержал победу!',
            elapsed_time_title = 'Матч длился %d с.',
            pause_info = 'Нажмите пробел для выхода в главное меню.',
            win_info = 'Нажмите пробел для нового матча.',
        },
    }

    self.langs_order = {'en', 'ru'}

    self.current_lang = 1
    if love.filesystem.exists(self.filename) then
        self.current_lang, _ = tonumber(love.filesystem.read(self.filename, 1), 10)
    end
end

function Locale:get(...)
    local lang = self.langs[self.langs_order[self.current_lang]]
    for _, v in ipairs({...}) do
        if not lang or not lang[v] then
            return '<???>'
        end
        lang = lang[v]
    end

    return lang
end

function Locale:next_language()
    self.current_lang = self.current_lang + 1
    if self.current_lang > #self.langs_order then
        self.current_lang = 1
    end

    love.filesystem.write(self.filename, self.current_lang, 1)
end

return Locale
