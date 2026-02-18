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

L["TIME_UNIT_YEAR"] = "y"
L["TIME_UNIT_DAY"] = "d"
L["TIME_UNIT_HOUR"] = "h"
L["TIME_UNIT_MINUTE"] = "m"

-- Delete command strings
L["CMD_DELETE_USAGE"]     = "Usage: /apdelete CharName-RealmName" -- (AI-GENERATED TRANSLATION)
L["CMD_DELETE_SUCCESS"]   = "Account Played: Removed '%s' from the database." -- (AI-GENERATED TRANSLATION)
L["CMD_DELETE_NOT_FOUND"] = "Account Played: Character '%s' not found in the database." -- (AI-GENERATED TRANSLATION)
L["CMD_DELETE_CONFIRM"]   = "Are you sure you want to remove |cffffff00%s|r from Account Played?" -- (AI-GENERATED TRANSLATION)


-- Character management panel strings
L["CHAR_PANEL_RIGHT_CLICK"] = "Right-Click to manage characters" -- (AI-GENERATED TRANSLATION)
L["CHAR_PANEL_REMOVE_TIP"]  = "Remove from Account Played" -- (AI-GENERATED TRANSLATION)
L["CLICK_TO_PRINT"] = "Left-Click to print in chat" -- (AI-GENERATED TRANSLATION)


if GetLocale() == "zhCN" then
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
