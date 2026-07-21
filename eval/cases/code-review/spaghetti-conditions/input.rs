pub fn process_user(user: &User, config: &Config) -> Result<ProcessedUser, Error> {
    let mut result = ProcessedUser::default();

    if user.is_active {
        if user.age > 18 {
            if user.email.contains('@') {
                if config.allow_international && user.country != "US" {
                    if user.verified {
                        result.status = "international_verified".to_string();
                    } else {
                        result.status = "international_unverified".to_string();
                    }
                } else {
                    if user.verified {
                        result.status = "domestic_verified".to_string();
                    } else {
                        result.status = "domestic_unverified".to_string();
                    }
                }
            } else {
                result.status = "invalid_email".to_string();
            }
        } else {
            result.status = "underage".to_string();
        }
    } else {
        result.status = "inactive".to_string();
    }

    Ok(result)
}
