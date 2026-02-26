local _, addonTable = ...

local L = {}
addonTable.L = L

L["ADDON_NAME"] = "Account Played"
L["WINDOW_TITLE"] = "Account Played - Time by Class"
L["NO_DATA"] = "No data yet"
L["TOTAL"] = "TOTAL: "
L["DEBUG_HEADER"] = "[AccountPlayed Debug] Known characters:"
L["DB_CORRUPTED"] = "Account Played: SavedVariables corrupted, resetting!"
L["USE_YEARS_LABEL"] = "Years"
L["TIME_FORMAT_TITLE"] = "Time Format"
L["TIME_FORMAT_YEARS"] = "Checked: Years/Days"
L["TIME_FORMAT_HOURS"] = "Unchecked: Hours/Minutes"

-- Minimap Button strings
L["TOOLTIP_TITLE"] = "Account Played"
L["TOOLTIP_LEFT_CLICK"] = "Left Click:"
L["TOOLTIP_RIGHT_CLICK"] = "Right Click:"
L["TOOLTIP_TOGGLE_WINDOW"] = "Toggle window"
L["TOOLTIP_DRAG_MOVE"] = "Drag:"
L["TOOLTIP_MOVE_ICON"] = "Move icon"
L["TOOLTIP_LOCK_UNLOCK"] = "Lock/Unlock position"

L["STATUS_LOCKED"] = "LOCKED"
L["STATUS_UNLOCKED"] = "UNLOCKED"

L["MSG_BUTTON_LOCKED"] = "Button is locked. Right-click to unlock."
L["MSG_BUTTON_STATUS"] = "Minimap button %s"
L["MSG_RESET_SUCCESS"] = "Minimap button position reset to default."
L["MSG_RESET_NEXT"] = "Minimap button will appear at default position on next login."

-- Slash command strings
L["MSG_MINIMAP_HIDDEN"]   = "Minimap icon hidden. Use /aplayed minimap to show it again."
L["MSG_MINIMAP_SHOWN"]    = "Minimap icon shown."
L["MSG_MINIMAP_NOT_INIT"] = "Minimap button not yet initialized."
L["CMD_HELP_HEADER"]      = "commands:"
L["CMD_HELP_MINIMAP_DESC"] = "toggle minimap icon on/off"
L["CMD_HELP_RESET_DESC"]   = "reset icon to default position and show it"
L["CMD_HELP_SHOW_DESC"]    = "toggle class time window"
L["MSG_CLASSWIN_DEPRECATED"] = "|cffff4400[DEPRECATED]|r /apclasswin will be removed in a future update. Please use |cffffff00/aplayed show|r instead."
L["MSG_CMD_DEPRECATED"]   = "|cffff4400[DEPRECATED]|r /apresetmap will be removed in a future update. Please use |cffffff00/aplayed reset|r instead."

L["TIME_UNIT_YEAR"] = "y"
L["TIME_UNIT_DAY"] = "d"
L["TIME_UNIT_HOUR"] = "h"
L["TIME_UNIT_MINUTE"] = "m"

-- Delete command strings
L["CMD_DELETE_USAGE"]     = "Usage: /apdelete CharName-RealmName"
L["CMD_DELETE_SUCCESS"]   = "Account Played: Removed '%s' from the database."
L["CMD_DELETE_NOT_FOUND"] = "Account Played: Character '%s' not found in the database."
L["CMD_DELETE_CONFIRM"]   = "Are you sure you want to remove |cffffff00%s|r from Account Played?"

-- Character management panel strings
L["CHAR_PANEL_RIGHT_CLICK"] = "Right-Click to manage characters"
L["CHAR_PANEL_REMOVE_TIP"]  = "Remove from Account Played"
L["CLICK_TO_PRINT"] = "Left-Click to print in chat"


if GetLocale() == "zhCN" then
  -- (Translator: https://github.com/SGSwdzgr)
    L["ADDON_NAME"] = "账号游戏时间"
    L["WINDOW_TITLE"] = "账号游戏时间 - 按职业统计"
    L["NO_DATA"] = "暂无数据"
    L["TOTAL"] = "总计: "
    L["DEBUG_HEADER"] = "[AccountPlayed调试] 已知角色:"
    L["DB_CORRUPTED"] = "Account Played: 存档数据损坏，已重置！"
    L["CLICK_TO_PRINT"] = "点击输出到聊天框"
    L["USE_YEARS_LABEL"] = "年份"
    L["TIME_FORMAT_TITLE"] = "时间格式"
    L["TIME_FORMAT_YEARS"] = "勾选: 年/天"
    L["TIME_FORMAT_HOURS"] = "未勾选: 小时/分钟"

    L["TOOLTIP_TITLE"] = "账号游戏时间"
    L["TOOLTIP_LEFT_CLICK"] = "左键:"
    L["TOOLTIP_RIGHT_CLICK"] = "右键:"
    L["TOOLTIP_TOGGLE_WINDOW"] = "切换窗口"
    L["TOOLTIP_DRAG_MOVE"] = "拖拽:"
    L["TOOLTIP_MOVE_ICON"] = "移动图标"
    L["TOOLTIP_LOCK_UNLOCK"] = "锁定/解锁位置"

    L["STATUS_LOCKED"] = "已锁定"
    L["STATUS_UNLOCKED"] = "未锁定"

    L["MSG_BUTTON_LOCKED"] = "图标已锁定。请右键点击解锁。"
    L["MSG_BUTTON_STATUS"] = "小地图图标 %s"
    L["MSG_RESET_SUCCESS"] = "小地图图标位置已重置为默认。"
    L["MSG_RESET_NEXT"] = "小地图图标将在下次登录时出现在默认位置。"

    -- Slash command strings
    L["MSG_MINIMAP_HIDDEN"]    = "小地图图标已隐藏。使用 /aplayed minimap 重新显示。" -- (AI-GENERATED TRANSLATION)
    L["MSG_MINIMAP_SHOWN"]     = "小地图图标已显示。" -- (AI-GENERATED TRANSLATION)
    L["MSG_MINIMAP_NOT_INIT"]  = "小地图按钮尚未初始化。" -- (AI-GENERATED TRANSLATION)
    L["CMD_HELP_HEADER"]       = "命令：" -- (AI-GENERATED TRANSLATION)
    L["CMD_HELP_MINIMAP_DESC"] = "切换小地图图标显示/隐藏" -- (AI-GENERATED TRANSLATION)
    L["CMD_HELP_RESET_DESC"]   = "重置图标到默认位置并显示" -- (AI-GENERATED TRANSLATION)
    L["CMD_HELP_SHOW_DESC"]    = "切换职业时间窗口" -- (AI-GENERATED TRANSLATION)
    L["MSG_CLASSWIN_DEPRECATED"] = "|cffff4400[已弃用]|r /apclasswin 将在未来版本中移除。请改用 |cffffff00/aplayed show|r。" -- (AI-GENERATED TRANSLATION)
    L["MSG_CMD_DEPRECATED"]    = "|cffff4400[已弃用]|r /apresetmap 将在未来版本中移除。请改用 |cffffff00/aplayed reset|r。" -- (AI-GENERATED TRANSLATION)

    L["TIME_UNIT_YEAR"] = "年"
    L["TIME_UNIT_DAY"] = "天"
    L["TIME_UNIT_HOUR"] = "小时"
    L["TIME_UNIT_MINUTE"] = "分钟"

    -- Delete command strings
    L["CMD_DELETE_USAGE"]     = "用法: /apdelete 角色名-服务器名"
    L["CMD_DELETE_SUCCESS"]   = "Account Played: 已从数据库中移除 '%s'。"
    L["CMD_DELETE_NOT_FOUND"] = "Account Played: 数据库中未找到角色 '%s'。"
    L["CMD_DELETE_CONFIRM"]   = "确定要从 Account Played 中移除 |cffffff00%s|r 吗？"

    -- Character management panel strings
    L["CHAR_PANEL_RIGHT_CLICK"] = "右键点击管理角色"
    L["CHAR_PANEL_REMOVE_TIP"]  = "从 Account Played 中移除"
end

if GetLocale() == "zhTW" then
  -- (Translator: https://github.com/SGSwdzgr)
    L["ADDON_NAME"] = "帳號遊戲時間"
    L["WINDOW_TITLE"] = "帳號遊戲時間 - 按職業統計"
    L["NO_DATA"] = "暫無資料"
    L["TOTAL"] = "總計: "
    L["DEBUG_HEADER"] = "[AccountPlayed調試] 已知角色:"
    L["DB_CORRUPTED"] = "Account Played: 存檔數據損壞，已重置！"
    L["CLICK_TO_PRINT"] = "點擊輸出到聊天視窗"
    L["USE_YEARS_LABEL"] = "年份"
    L["TIME_FORMAT_TITLE"] = "時間格式"
    L["TIME_FORMAT_YEARS"] = "勾選: 年/天"
    L["TIME_FORMAT_HOURS"] = "未勾選: 小時/分鐘"

    L["TOOLTIP_TITLE"] = "帳號遊戲時間"
    L["TOOLTIP_LEFT_CLICK"] = "左鍵:"
    L["TOOLTIP_RIGHT_CLICK"] = "右鍵:"
    L["TOOLTIP_TOGGLE_WINDOW"] = "切換視窗"
    L["TOOLTIP_DRAG_MOVE"] = "拖曳:"
    L["TOOLTIP_MOVE_ICON"] = "移動圖示"
    L["TOOLTIP_LOCK_UNLOCK"] = "鎖定/解鎖位置"

    L["STATUS_LOCKED"] = "已鎖定"
    L["STATUS_UNLOCKED"] = "未鎖定"

    L["MSG_BUTTON_LOCKED"] = "圖示已鎖定。請右鍵點擊解鎖。"
    L["MSG_BUTTON_STATUS"] = "小地圖圖示 %s"
    L["MSG_RESET_SUCCESS"] = "小地圖圖示位置已重置為默認。"
    L["MSG_RESET_NEXT"] = "小地圖圖示將在下次登錄時出現在默認位置。"

    -- Slash command strings
    L["MSG_MINIMAP_HIDDEN"]    = "小地圖圖示已隱藏。使用 /aplayed minimap 重新顯示。" -- (AI-GENERATED TRANSLATION)
    L["MSG_MINIMAP_SHOWN"]     = "小地圖圖示已顯示。" -- (AI-GENERATED TRANSLATION)
    L["MSG_MINIMAP_NOT_INIT"]  = "小地圖按鈕尚未初始化。" -- (AI-GENERATED TRANSLATION)
    L["CMD_HELP_HEADER"]       = "命令：" -- (AI-GENERATED TRANSLATION)
    L["CMD_HELP_MINIMAP_DESC"] = "切換小地圖圖示顯示/隱藏" -- (AI-GENERATED TRANSLATION)
    L["CMD_HELP_RESET_DESC"]   = "重置圖示到默認位置並顯示" -- (AI-GENERATED TRANSLATION)
    L["CMD_HELP_SHOW_DESC"]    = "切換職業時間視窗" -- (AI-GENERATED TRANSLATION)
    L["MSG_CLASSWIN_DEPRECATED"] = "|cffff4400[已棄用]|r /apclasswin 將在未來版本中移除。請改用 |cffffff00/aplayed show|r。" -- (AI-GENERATED TRANSLATION)
    L["MSG_CMD_DEPRECATED"]    = "|cffff4400[已棄用]|r /apresetmap 將在未來版本中移除。請改用 |cffffff00/aplayed reset|r。" -- (AI-GENERATED TRANSLATION)

    L["TIME_UNIT_YEAR"] = "年"
    L["TIME_UNIT_DAY"] = "天"
    L["TIME_UNIT_HOUR"] = "小時"
    L["TIME_UNIT_MINUTE"] = "分鐘"

    -- Delete command strings
    L["CMD_DELETE_USAGE"]     = "用法: /apdelete 角色名-伺服器名" -- (AI-GENERATED TRANSLATION)
    L["CMD_DELETE_SUCCESS"]   = "Account Played: 已從資料庫中移除 '%s'。" -- (AI-GENERATED TRANSLATION)
    L["CMD_DELETE_NOT_FOUND"] = "Account Played: 資料庫中未找到角色 '%s'。" -- (AI-GENERATED TRANSLATION)
    L["CMD_DELETE_CONFIRM"]   = "確定要從 Account Played 中移除 |cffffff00%s|r 嗎？" -- (AI-GENERATED TRANSLATION)

    -- Character management panel strings
    L["CHAR_PANEL_RIGHT_CLICK"] = "右鍵點擊管理角色" -- (AI-GENERATED TRANSLATION)
    L["CHAR_PANEL_REMOVE_TIP"]  = "從 Account Played 中移除" -- (AI-GENERATED TRANSLATION)
end

if GetLocale() == "frFR" then
  -- Translator: https://github.com/ZelionGG
    L["ADDON_NAME"] = "Account Played"
    L["WINDOW_TITLE"] = "Account Played - Temps par Classe"
    L["NO_DATA"] = "Aucune donnée"
    L["TOTAL"] = "Total : "
    L["DEBUG_HEADER"] = "[AccountPlayed Debug] Personnages connus :"
    L["DB_CORRUPTED"] = "Account Played: SavedVariables corrompu, réinitialisation!"
    L["USE_YEARS_LABEL"] = "Années"
    L["TIME_FORMAT_TITLE"] = "Format de temps"
    L["TIME_FORMAT_YEARS"] = "Coché: Années/Jours"
    L["TIME_FORMAT_HOURS"] = "Non coché: Heures/Minutes"

    -- Minimap Button strings
    L["TOOLTIP_TITLE"] = "Account Played"
    L["TOOLTIP_LEFT_CLICK"] = "Clic gauche :"
    L["TOOLTIP_RIGHT_CLICK"] = "Clic droit :"
    L["TOOLTIP_TOGGLE_WINDOW"] = "Ouvrir la fenêtre"
    L["TOOLTIP_DRAG_MOVE"] = "Déplacer :"
    L["TOOLTIP_MOVE_ICON"] = "Déplacer l'icône"
    L["TOOLTIP_LOCK_UNLOCK"] = "Verrouiller/Déverrouiller la position de l'icône"

    L["STATUS_LOCKED"] = "VERROUILLÉ"
    L["STATUS_UNLOCKED"] = "DEVERROUILLÉ"

    L["MSG_BUTTON_LOCKED"] = "Le bouton est verrouillé. Clic droit pour deverrouiller."
    L["MSG_BUTTON_STATUS"] = "Bouton de la minicarte %s"
    L["MSG_RESET_SUCCESS"] = "Position du bouton de la minicarte réinitialisée à la valeur par défaut."
    L["MSG_RESET_NEXT"] = "Le bouton de la minicarte apparaîtra à la position par défaut lors du prochain login."

    -- Slash command strings
    L["MSG_MINIMAP_HIDDEN"]    = "Icône de la minicarte masquée. Utilisez /aplayed minimap pour la réafficher." -- (AI-GENERATED TRANSLATION)
    L["MSG_MINIMAP_SHOWN"]     = "Icône de la minicarte affichée." -- (AI-GENERATED TRANSLATION)
    L["MSG_MINIMAP_NOT_INIT"]  = "Le bouton de la minicarte n'est pas encore initialisé." -- (AI-GENERATED TRANSLATION)
    L["CMD_HELP_HEADER"]       = "commandes :" -- (AI-GENERATED TRANSLATION)
    L["CMD_HELP_MINIMAP_DESC"] = "afficher/masquer l'icône de la minicarte" -- (AI-GENERATED TRANSLATION)
    L["CMD_HELP_RESET_DESC"]   = "réinitialiser l'icône à sa position par défaut et l'afficher" -- (AI-GENERATED TRANSLATION)
    L["CMD_HELP_SHOW_DESC"]    = "afficher/masquer la fenêtre des temps par classe" -- (AI-GENERATED TRANSLATION)
    L["MSG_CLASSWIN_DEPRECATED"] = "|cffff4400[OBSOLÈTE]|r /apclasswin sera supprimé dans une future mise à jour. Veuillez utiliser |cffffff00/aplayed show|r à la place." -- (AI-GENERATED TRANSLATION)
    L["MSG_CMD_DEPRECATED"]    = "|cffff4400[OBSOLÈTE]|r /apresetmap sera supprimé dans une future mise à jour. Veuillez utiliser |cffffff00/aplayed reset|r à la place." -- (AI-GENERATED TRANSLATION)

    L["TIME_UNIT_YEAR"] = "a"
    L["TIME_UNIT_DAY"] = "j"
    L["TIME_UNIT_HOUR"] = "h"
    L["TIME_UNIT_MINUTE"] = "m"

    -- Delete command strings
    L["CMD_DELETE_USAGE"]     = "Utilisation : /apdelete NomPersonnage-NomServeur"
    L["CMD_DELETE_SUCCESS"]   = "Account Played : '%s' supprimé de la base de données."
    L["CMD_DELETE_NOT_FOUND"] = "Account Played : Personnage '%s' non trouvé dans la base de données."
    L["CMD_DELETE_CONFIRM"]   = "Êtes-vous sûr de vouloir supprimer |cffffff00%s|r de Account Played?"

    -- Character management panel strings
    L["CHAR_PANEL_RIGHT_CLICK"] = "Clic droit pour gérer les personnages"
    L["CHAR_PANEL_REMOVE_TIP"]  = "Supprimer de Account Played"
    L["CLICK_TO_PRINT"] = "Clic gauche pour afficher dans le chat"
end

if GetLocale() == "ruRU" then
 -- Translator ZamestoTV   
   L["ADDON_NAME"] = "Account Played"
   L["WINDOW_TITLE"] = "Общее время - по классам"
   L["NO_DATA"] = "Нет данных"
   L["TOTAL"] = "ИТОГО: "
   L["DEBUG_HEADER"] = "[AccountPlayed Debug] Список персонажей:"
   L["DB_CORRUPTED"] = "Account Played: Файл настроек поврежден, сброс!"
   L["USE_YEARS_LABEL"] = "Года"
   L["TIME_FORMAT_TITLE"] = "Формат времени"
   L["TIME_FORMAT_YEARS"] = "Выбрано: Года/Дни"
   L["TIME_FORMAT_HOURS"] = "Выбрано: Часы/Минуты"

-- Minimap Button strings
   L["TOOLTIP_TITLE"] = "Account Played"
   L["TOOLTIP_LEFT_CLICK"] = "ЛКМ:"
   L["TOOLTIP_RIGHT_CLICK"] = "ПКМ:"
   L["TOOLTIP_TOGGLE_WINDOW"] = "Открыть/закрыть окно"
   L["TOOLTIP_DRAG_MOVE"] = "Перетаскивание:"
   L["TOOLTIP_MOVE_ICON"] = "Переместить иконку"
   L["TOOLTIP_LOCK_UNLOCK"] = "Закрепить/открепить положение"

   L["STATUS_LOCKED"] = "ЗАКРЕПЛЕНО"
   L["STATUS_UNLOCKED"] = "НЕ ЗАКРЕПЛЕНО"

   L["MSG_BUTTON_LOCKED"] = "Кнопка закреплена. ПКМ, чтобы открепить."
   L["MSG_BUTTON_STATUS"] = "Кнопка у миникарты: %s"
   L["MSG_RESET_SUCCESS"] = "Позиция кнопки сброшена."
   L["MSG_RESET_NEXT"] = "Кнопка вернется в исходное положение при следующем входе."

-- Slash command strings
   L["MSG_MINIMAP_HIDDEN"]   = "Иконка скрыта. Введите /aplayed minimap, чтобы вернуть её."
   L["MSG_MINIMAP_SHOWN"]    = "Иконка на миникарте отображена."
   L["MSG_MINIMAP_NOT_INIT"] = "Кнопка миникарты еще не загружена."
   L["CMD_HELP_HEADER"]      = "Доступные команды:"
   L["CMD_HELP_MINIMAP_DESC"] = "включить/выключить иконку миникарты"
   L["CMD_HELP_RESET_DESC"]   = "сбросить положение иконки и показать её"
   L["CMD_HELP_SHOW_DESC"]    = "показать/скрыть окно времени по классам"
   L["MSG_CLASSWIN_DEPRECATED"] = "|cffff4400[УСТАРЕЛО]|r Команда /apclasswin будет удалена. Используйте |cffffff00/aplayed show|r."
   L["MSG_CMD_DEPRECATED"]   = "|cffff4400[УСТАРЕЛО]|r Команда /apresetmap будет удалена. Используйте |cffffff00/aplayed reset|r."

   L["TIME_UNIT_YEAR"] = "г."
   L["TIME_UNIT_DAY"] = "д."
   L["TIME_UNIT_HOUR"] = "ч."
   L["TIME_UNIT_MINUTE"] = "м."

-- Delete command strings
   L["CMD_DELETE_USAGE"]     = "Использование: /apdelete Имя-Сервер"
   L["CMD_DELETE_SUCCESS"]   = "Account Played: Персонаж '%s' удален."
   L["CMD_DELETE_NOT_FOUND"] = "Account Played: Персонаж '%s' не найден."
   L["CMD_DELETE_CONFIRM"]   = "Вы уверены, что хотите удалить |cffffff00%s|r из базы данных?"

-- Character management panel strings
   L["CHAR_PANEL_RIGHT_CLICK"] = "ПКМ: управление персонажами"
   L["CHAR_PANEL_REMOVE_TIP"]  = "Удалить из списка"
   L["CLICK_TO_PRINT"] = "ЛКМ: вывести данные в чат"
end

if GetLocale() == "deDE" then
	L["ADDON_NAME"] = "Account Played"
	L["WINDOW_TITLE"] = "Account Played - Spielzeit nach Klasse"
	L["NO_DATA"] = "Noch keine Daten"
	L["TOTAL"] = "GESAMT: "
	L["DEBUG_HEADER"] = "[AccountPlayed Debug] Bekannte Charaktere:"
	L["DB_CORRUPTED"] = "Account Played: Gespeicherte Variablen beschädigt, setze zurück!"
	L["USE_YEARS_LABEL"] = "Jahre"
	L["TIME_FORMAT_TITLE"] = "Zeitformat"
	L["TIME_FORMAT_YEARS"] = "Aktiviert: Jahre/Tage"
	L["TIME_FORMAT_HOURS"] = "Deaktiviert: Stunden/Minuten"

	-- Minimap-Button Texte
	L["TOOLTIP_TITLE"] = "Account Played"
	L["TOOLTIP_LEFT_CLICK"] = "Linksklick:"
	L["TOOLTIP_RIGHT_CLICK"] = "Rechtsklick:"
	L["TOOLTIP_TOGGLE_WINDOW"] = "Fenster ein-/ausblenden"
	L["TOOLTIP_DRAG_MOVE"] = "Ziehen:"
	L["TOOLTIP_MOVE_ICON"] = "Symbol verschieben"
	L["TOOLTIP_LOCK_UNLOCK"] = "Position sperren/entsperren"

	L["STATUS_LOCKED"] = "GESPERRT"
	L["STATUS_UNLOCKED"] = "ENTSPERRT"

	L["MSG_BUTTON_LOCKED"] = "Button ist gesperrt. Rechtsklick zum Entsperren."
	L["MSG_BUTTON_STATUS"] = "Minimap-Button %s"
	L["MSG_RESET_SUCCESS"] = "Position des Minimap-Buttons auf Standard zurückgesetzt."
	L["MSG_RESET_NEXT"] = "Der Minimap-Button erscheint beim nächsten Login an der Standardposition."

	-- Slash-Befehle Texte
	L["MSG_MINIMAP_HIDDEN"]   = "Minimap-Symbol ausgeblendet. Mit /aplayed minimap wieder anzeigen."
	L["MSG_MINIMAP_SHOWN"]    = "Minimap-Symbol angezeigt."
	L["MSG_MINIMAP_NOT_INIT"] = "Minimap-Button noch nicht initialisiert."
	L["CMD_HELP_HEADER"]      = "Befehle:"
	L["CMD_HELP_MINIMAP_DESC"] = "Minimap-Symbol ein-/ausblenden"
	L["CMD_HELP_RESET_DESC"]   = "Symbol auf Standardposition zurücksetzen und anzeigen"
	L["CMD_HELP_SHOW_DESC"]    = "Klassen-Spielzeitfenster ein-/ausblenden"
	L["MSG_CLASSWIN_DEPRECATED"] = "|cffff4400[VERALTET]|r /apclasswin wird in einem zukünftigen Update entfernt. Bitte stattdessen |cffffff00/aplayed show|r verwenden."
	L["MSG_CMD_DEPRECATED"]   = "|cffff4400[VERALTET]|r /apresetmap wird in einem zukünftigen Update entfernt. Bitte stattdessen |cffffff00/aplayed reset|r verwenden."

	L["TIME_UNIT_YEAR"] = " J"
	L["TIME_UNIT_DAY"] = " T"
	L["TIME_UNIT_HOUR"] = " Std"
	L["TIME_UNIT_MINUTE"] = " Min"

	-- Löschbefehl Texte
	L["CMD_DELETE_USAGE"]     = "Verwendung: /apdelete Charaktername-Servername"
	L["CMD_DELETE_SUCCESS"]   = "Account Played: '%s' wurde aus der Datenbank entfernt."
	L["CMD_DELETE_NOT_FOUND"] = "Account Played: Charakter '%s' wurde in der Datenbank nicht gefunden."
	L["CMD_DELETE_CONFIRM"]   = "Möchtest du |cffffff00%s|r wirklich aus Account Played entfernen?"

	-- Charakterverwaltungs-Panel Texte
	L["CHAR_PANEL_RIGHT_CLICK"] = "Rechtsklick zur Charakterverwaltung"
	L["CHAR_PANEL_REMOVE_TIP"]  = "Aus Account Played entfernen"
	L["CLICK_TO_PRINT"] = "Linksklick zum Ausgeben im Chat"
end

if GetLocale() == "esMX" then
   L["ADDON_NAME"] = "Account Played"
   L["WINDOW_TITLE"] = "Account Played  - Tiempo por Clase"
   L["NO_DATA"] = "Sin información"
   L["TOTAL"] = "TOTAL:"
   L["DEBUG_HEADER"] = "[AccountPlayed Debug] Personajes conocidos:"
   L["DB_CORRUPTED"] = "Account Played: SavedVariables corruptos, reiniciando!"
   L["CLICK_TO_PRINT"] = "Click Izquierdo para imprimir en el chat"
   L["USE_YEARS_LABEL"] = "Años"
   L["TIME_FORMAT_TITLE"] = "Formato del Tiempo"
   L["TIME_FORMAT_YEARS"] = "Marcar: Años/Días"
   L["TIME_FORMAT_HOURS"] = "Desmarcar: Horas/Minutos"

   L["TOOLTIP_TITLE"] = "Account Played"
   L["TOOLTIP_LEFT_CLICK"] = "Click Izquierdo:"
   L["TOOLTIP_RIGHT_CLICK"] = "Click derecho:"
   L["TOOLTIP_TOGGLE_WINDOW"] = "Alternar ventana"
   L["TOOLTIP_DRAG_MOVE"] = "Arrastrar:"
   L["TOOLTIP_MOVE_ICON"] = "Mover Icono"
   L["TOOLTIP_LOCK_UNLOCK"] = "Bloquear/Desbloquear posición"

   L["STATUS_LOCKED"] = "BLOQUEADO"
   L["STATUS_UNLOCKED"] = "DESBLOQUEADO"

   L["MSG_BUTTON_LOCKED"] = "Botón está bloqueado. Click-Derecho para desbloquear"
   L["MSG_BUTTON_STATUS"] = "Botón del minimapa %s"
   L["MSG_RESET_SUCCESS"] = "Posición del botón del minimapa restablecida a la predeterminada."
   L["MSG_RESET_NEXT"] = "El botón del minimapa aparecerá en la posición predeterminada en el próximo inicio de sesión."

   -- Slash command strings
   L["MSG_MINIMAP_HIDDEN"]    = "Icono del minimapa oculto. Usa /aplayed minimap para mostrarlo de nuevo."
   L["MSG_MINIMAP_SHOWN"]     = "Icono del minimapa mostrado."
   L["MSG_MINIMAP_NOT_INIT"]  = "El botón del minimapa aún no ha sido inicializado."
   L["CMD_HELP_HEADER"]       = "comandos:"
   L["CMD_HELP_MINIMAP_DESC"] = "activar/desactivar icono del minimapa"
   L["CMD_HELP_RESET_DESC"]   = "Reestablecer icono a la posición predeterminada y mostrarlo"
   L["CMD_HELP_SHOW_DESC"]    = "alternar ventana de tiempo por clase"
   L["MSG_CLASSWIN_DEPRECATED"] = "|cffff4400[OBSOLETO]|r /apclasswin será eliminado en una futura actualización. Por favor usa |cffffff00/aplayed show|r en su lugar."
   L["MSG_CMD_DEPRECATED"]    = "|cffff4400[OBSOLETO]|r /apresetmap será eliminado en una futura actualización. Por favor usa |cffffff00/aplayed reset|r en su lugar."

   L["TIME_UNIT_YEAR"] = "a"
   L["TIME_UNIT_DAY"] = "d"
   L["TIME_UNIT_HOUR"] = "h"
   L["TIME_UNIT_MINUTE"] = "m"

   -- Delete command strings
   L["CMD_DELETE_USAGE"]     = "Uso: /apdelete Personaje-Reino"
   L["CMD_DELETE_SUCCESS"]   = "Account Played: Eliminó '%s' de la base de datos"
   L["CMD_DELETE_NOT_FOUND"] = "Account Played: Personaje '%s' no se encontró en la base de datos"
   L["CMD_DELETE_CONFIRM"]   = "¿Estás seguro de que quieres quitar |cffffff00%s|r de Account Played?"

   -- Character management panel strings
   L["CHAR_PANEL_RIGHT_CLICK"] = "Click-Derecho para administrar personajes"
   L["CHAR_PANEL_REMOVE_TIP"]  = "Quitar de Account Played"
end

if GetLocale() == "esES" then
   L["ADDON_NAME"] = "Account Played"
   L["WINDOW_TITLE"] = "Account Played  - Tiempo por Clase"
   L["NO_DATA"] = "Sin información"
   L["TOTAL"] = "TOTAL:"
   L["DEBUG_HEADER"] = "[AccountPlayed Debug] Personajes conocidos:"
   L["DB_CORRUPTED"] = "Account Played: SavedVariables corruptos, reiniciando!"
   L["CLICK_TO_PRINT"] = "Click Izquierdo para imprimir en el chat"
   L["USE_YEARS_LABEL"] = "Años"
   L["TIME_FORMAT_TITLE"] = "Formato del Tiempo"
   L["TIME_FORMAT_YEARS"] = "Marcar: Años/Días"
   L["TIME_FORMAT_HOURS"] = "Desmarcar: Horas/Minutos"

   L["TOOLTIP_TITLE"] = "Account Played"
   L["TOOLTIP_LEFT_CLICK"] = "Click Izquierdo:"
   L["TOOLTIP_RIGHT_CLICK"] = "Click derecho:"
   L["TOOLTIP_TOGGLE_WINDOW"] = "Alternar ventana"
   L["TOOLTIP_DRAG_MOVE"] = "Arrastrar:"
   L["TOOLTIP_MOVE_ICON"] = "Mover Icono"
   L["TOOLTIP_LOCK_UNLOCK"] = "Bloquear/Desbloquear posición"

   L["STATUS_LOCKED"] = "BLOQUEADO"
   L["STATUS_UNLOCKED"] = "DESBLOQUEADO"

   L["MSG_BUTTON_LOCKED"] = "Botón está bloqueado. Click-Derecho para desbloquear"
   L["MSG_BUTTON_STATUS"] = "Botón del minimapa %s"
   L["MSG_RESET_SUCCESS"] = "Posición del botón del minimapa restablecida a la predeterminada."
   L["MSG_RESET_NEXT"] = "El botón del minimapa aparecerá en la posición predeterminada en el próximo inicio de sesión."

   -- Slash command strings
   L["MSG_MINIMAP_HIDDEN"]    = "Icono del minimapa oculto. Usa /aplayed minimap para mostrarlo de nuevo."
   L["MSG_MINIMAP_SHOWN"]     = "Icono del minimapa mostrado."
   L["MSG_MINIMAP_NOT_INIT"]  = "El botón del minimapa aún no ha sido inicializado."
   L["CMD_HELP_HEADER"]       = "comandos:"
   L["CMD_HELP_MINIMAP_DESC"] = "activar/desactivar icono del minimapa"
   L["CMD_HELP_RESET_DESC"]   = "Reestablecer icono a la posición predeterminada y mostrarlo"
   L["CMD_HELP_SHOW_DESC"]    = "alternar ventana de tiempo por clase"
   L["MSG_CLASSWIN_DEPRECATED"] = "|cffff4400[OBSOLETO]|r /apclasswin será eliminado en una futura actualización. Por favor usa |cffffff00/aplayed show|r en su lugar."
   L["MSG_CMD_DEPRECATED"]    = "|cffff4400[OBSOLETO]|r /apresetmap será eliminado en una futura actualización. Por favor usa |cffffff00/aplayed reset|r en su lugar."

   L["TIME_UNIT_YEAR"] = "a"
   L["TIME_UNIT_DAY"] = "d"
   L["TIME_UNIT_HOUR"] = "h"
   L["TIME_UNIT_MINUTE"] = "m"

   -- Delete command strings
   L["CMD_DELETE_USAGE"]     = "Uso: /apdelete Personaje-Reino"
   L["CMD_DELETE_SUCCESS"]   = "Account Played: Eliminó '%s' de la base de datos"
   L["CMD_DELETE_NOT_FOUND"] = "Account Played: Personaje '%s' no se encontró en la base de datos"
   L["CMD_DELETE_CONFIRM"]   = "¿Estás seguro de que quieres quitar |cffffff00%s|r de Account Played?"

   -- Character management panel strings
   L["CHAR_PANEL_RIGHT_CLICK"] = "Click-Derecho para administrar personajes"
   L["CHAR_PANEL_REMOVE_TIP"]  = "Quitar de Account Played"
end

if GetLocale() == "ptBR" then
   L["ADDON_NAME"] = "Account Played"
   L["WINDOW_TITLE"] = "Account Played - Tempo por Classe"
   L["NO_DATA"] = "Sem informação"
   L["TOTAL"] = "TOTAL:"
   L["DEBUG_HEADER"] = "[AccountPlayed Debug] Personagens conhecidos:"
   L["DB_CORRUPTED"] = "Account Played: SavedVariables corrompido, reiniciando!"
   L["CLICK_TO_PRINT"] = "Clique Esquerdo para imprimir no chat"
   L["USE_YEARS_LABEL"] = "Anos"
   L["TIME_FORMAT_TITLE"] = "Formato de Tempo"
   L["TIME_FORMAT_YEARS"] = "Marcado: Anos/Dias"
   L["TIME_FORMAT_HOURS"] = "Desmarcado: Horas/Minutos"

   L["TOOLTIP_TITLE"] = "Account Played"
   L["TOOLTIP_LEFT_CLICK"] = "Clique Esquerdo:"
   L["TOOLTIP_RIGHT_CLICK"] = "Clique Direito:"
   L["TOOLTIP_TOGGLE_WINDOW"] = "Alternar janela"
   L["TOOLTIP_DRAG_MOVE"] = "Arrastar:"
   L["TOOLTIP_MOVE_ICON"] = "Mover Ícone"
   L["TOOLTIP_LOCK_UNLOCK"] = "Bloquear/Desbloquear posição"

   L["STATUS_LOCKED"] = "BLOQUEADO"
   L["STATUS_UNLOCKED"] = "DESBLOQUEADO"

   L["MSG_BUTTON_LOCKED"] = "Botão está bloqueado. Clique-Direito para desbloquear."
   L["MSG_BUTTON_STATUS"] = "Botão do minimapa %s"
   L["MSG_RESET_SUCCESS"] = "Posição do botão do minimapa redefinida para o padrão."
   L["MSG_RESET_NEXT"] = "O botão do minimapa aparecerá na posição padrão no próximo login."

   L["MSG_MINIMAP_HIDDEN"]    = "Ícone do minimapa oculto. Use /aplayed minimap para exibi-lo novamente."
   L["MSG_MINIMAP_SHOWN"]     = "Ícone do minimapa exibido."
   L["MSG_MINIMAP_NOT_INIT"]  = "O botão do minimapa ainda não foi inicializado."
   L["CMD_HELP_HEADER"]       = "comandos:"
   L["CMD_HELP_MINIMAP_DESC"] = "ativar/desativar ícone do minimapa"
   L["CMD_HELP_RESET_DESC"]   = "Redefinir ícone para a posição padrão e exibi-lo"
   L["CMD_HELP_SHOW_DESC"]    = "alternar janela de tempo por classe"
   L["MSG_CLASSWIN_DEPRECATED"] = "|cffff4400[OBSOLETO]|r /apclasswin será removido em uma atualização futura. Por favor use |cffffff00/aplayed show|r em seu lugar."
   L["MSG_CMD_DEPRECATED"]    = "|cffff4400[OBSOLETO]|r /apresetmap será removido em uma atualização futura. Por favor use |cffffff00/aplayed reset|r em seu lugar."

   L["TIME_UNIT_YEAR"] = "a"
   L["TIME_UNIT_DAY"] = "d"
   L["TIME_UNIT_HOUR"] = "h"
   L["TIME_UNIT_MINUTE"] = "m"

   L["CMD_DELETE_USAGE"]     = "Uso: /apdelete Personagem-Reino"
   L["CMD_DELETE_SUCCESS"]   = "Account Played: Removeu '%s' do banco de dados."
   L["CMD_DELETE_NOT_FOUND"] = "Account Played: Personagem '%s' não encontrado no banco de dados."
   L["CMD_DELETE_CONFIRM"]   = "Tem certeza que deseja remover |cffffff00%s|r do Account Played?"

   L["CHAR_PANEL_RIGHT_CLICK"] = "Clique-Direito para gerenciar personagens"
   L["CHAR_PANEL_REMOVE_TIP"]  = "Remover do Account Played"
end
