use std::sync::Arc;
use tokio::sync::RwLock;

pub struct UserService {
    db: Arc<dyn Database>,
    cache: Arc<RwLock<Cache>>,
    mailer: Arc<dyn Mailer>,
    logger: Arc<dyn Logger>,
    config: Arc<Config>,
}

impl UserService {
    pub async fn create_user(&self, email: &str, password: &str) -> Result<User, Error> {
        let hash = self.hash_password(password).await?;
        let user = self.db.create_user(email, &hash).await?;
        self.cache.write().await.insert(&user.id, &user);
        self.mailer.send_welcome(email).await?;
        self.logger.info(&format!("Created user: {}", user.id));
        Ok(user)
    }

    pub async fn delete_user(&self, id: i64) -> Result<(), Error> {
        let user = self.db.get_user(id).await?;
        self.db.delete_user(id).await?;
        self.cache.write().await.remove(&id);
        self.mailer.send_goodbye(&user.email).await?;
        self.logger.info(&format!("Deleted user: {}", id));
        Ok(())
    }

    async fn hash_password(&self, password: &str) -> Result<String, Error> {
        todo!()
    }
}
