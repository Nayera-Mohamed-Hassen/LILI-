import http from 'k6/http';

export let options = {
  vus: 100, // Number of concurrent users (virtual users)
  duration: '10s', // Total test duration
};

export default function () {
  http.get('http://localhost:8000/user/profile/d99f7950-2254-44ad-8ec9-1fdb9ed661c5');
} 