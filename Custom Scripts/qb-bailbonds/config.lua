-- config.lua
Config = {}

Config.AuthorizedJobs = {
    "leo",
    "judge"
}

Config.BailCheckInterval = 60000 -- milliseconds (1 minute)

Config.Locales = {
    ['bail_set'] = "Your bail has been set to $%s for %s hours.",
    ['not_authorized'] = "You are not authorized to perform this action.",
    ['target_not_found'] = "Target player not found.",
    ['db_error'] = "Database error occurred.",
    ['no_active_bail'] = "You don't have any active bail.",
    ['bail_already_paid'] = "Your bail has already been paid.",
    ['not_enough_cash'] = "You don't have enough cash to pay the bail.",
    ['bail_paid'] = "Bail paid successfully. You are now free.",
    ['bail_expired'] = "Your bail has expired.",
    ['bail_revoked'] = "Your bail has been revoked.",
    ['no_bail_to_revoke'] = "Target player does not have an active bail.",
}

