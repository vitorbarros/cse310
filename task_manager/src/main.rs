use std::sync::{
    atomic::{AtomicU64, Ordering},
    Arc, Mutex,
};

use axum::{
    extract::{Path, State},
    http::StatusCode,
    routing::{delete, get, post, put},
    Json, Router,
};
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize)]
struct Task {
    id: u64,
    title: String,
    completed: bool,
}

#[derive(Debug, Deserialize)]
struct CreateTask {
    title: String,
}

#[derive(Debug, Deserialize)]
struct UpdateTask {
    title: Option<String>,
    completed: Option<bool>,
}

#[derive(Debug, Default)]
struct AppState {
    tasks: Mutex<Vec<Task>>,
    next_id: AtomicU64,
}

#[tokio::main]
async fn main() {
    let state = Arc::new(AppState::default());

    let app = Router::new()
        .route("/tasks", get(list_tasks).post(create_task))
        .route("/tasks/:id", get(get_task).put(update_task).delete(delete_task))
        .with_state(state);

    let listener = tokio::net::TcpListener::bind("127.0.0.1:3000")
        .await
        .expect("failed to bind address");

    axum::serve(listener, app)
        .await
        .expect("server error");
}

async fn list_tasks(State(state): State<Arc<AppState>>) -> Json<Vec<Task>> {
    let tasks = state.tasks.lock().expect("tasks lock poisoned");
    Json(tasks.clone())
}

async fn create_task(
    State(state): State<Arc<AppState>>,
    Json(payload): Json<CreateTask>,
) -> (StatusCode, Json<Task>) {
    let id = state.next_id.fetch_add(1, Ordering::Relaxed) + 1;
    let task = Task {
        id,
        title: payload.title,
        completed: false,
    };

    let mut tasks = state.tasks.lock().expect("tasks lock poisoned");
    tasks.push(task.clone());

    (StatusCode::CREATED, Json(task))
}

async fn get_task(
    State(state): State<Arc<AppState>>,
    Path(id): Path<u64>,
) -> Result<Json<Task>, StatusCode> {
    let tasks = state.tasks.lock().expect("tasks lock poisoned");
    tasks
        .iter()
        .find(|task| task.id == id)
        .cloned()
        .map(Json)
        .ok_or(StatusCode::NOT_FOUND)
}

async fn update_task(
    State(state): State<Arc<AppState>>,
    Path(id): Path<u64>,
    Json(payload): Json<UpdateTask>,
) -> Result<Json<Task>, StatusCode> {
    let mut tasks = state.tasks.lock().expect("tasks lock poisoned");
    let task = tasks.iter_mut().find(|task| task.id == id);

    match task {
        Some(task) => {
            if let Some(title) = payload.title {
                task.title = title;
            }
            if let Some(completed) = payload.completed {
                task.completed = completed;
            }
            Ok(Json(task.clone()))
        }
        None => Err(StatusCode::NOT_FOUND),
    }
}

async fn delete_task(
    State(state): State<Arc<AppState>>,
    Path(id): Path<u64>,
) -> Result<StatusCode, StatusCode> {
    let mut tasks = state.tasks.lock().expect("tasks lock poisoned");
    let index = tasks.iter().position(|task| task.id == id);

    match index {
        Some(index) => {
            tasks.remove(index);
            Ok(StatusCode::NO_CONTENT)
        }
        None => Err(StatusCode::NOT_FOUND),
    }
}
