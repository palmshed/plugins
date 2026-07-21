use actix_web::{web, HttpRequest, HttpResponse};

pub async fn delete_document(req: HttpRequest, doc_id: web::Path<Uuid>) -> HttpResponse {
    let doc_id = doc_id.into_inner();
    delete_document_from_db(doc_id).await;
    HttpResponse::Ok().finish()
}

pub async fn update_settings(req: HttpRequest, body: web::Json<Settings>) -> HttpResponse {
    let settings = body.into_inner();
    save_settings(settings).await;
    HttpResponse::Ok().finish()
}

pub async fn export_data(req: HttpRequest) -> HttpResponse {
    let data = fetch_all_data().await;
    HttpResponse::Ok().json(data)
}
