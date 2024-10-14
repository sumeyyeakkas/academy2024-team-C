import React, { useState, useEffect } from 'react';
import axios from 'axios';

function App() {
  const [name, setName] = useState('');
  const [greeting, setGreeting] = useState('');

  useEffect(() => {
    document.body.className = 'bg-gradient-to-r from-orange-700 to-purple-700';
  }, []);

  const fetchGreeting = async () => {
    try {
      const response = await axios.get(`http://localhost:8080/${name}`);
      setGreeting(response.data.message);
    } catch (error) {
      console.error('Mesaj alınırken hata oluştu:', error);
      setGreeting('Üzgünüm, bir hata oluştu.');
    }
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    fetchGreeting();
  };

  return (
    <div className="min-h-screen flex items-center justify-center">
      <div className="bg-white p-8 rounded-lg shadow-xl max-w-md w-full">
        <h1 className="text-3xl font-bold mb-6 text-center text-gray-800">Academy 2024 BCFM</h1>
        <form onSubmit={handleSubmit} className="mb-4">
          <input
            type="text"
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="Adınızı girin"
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 mb-4"
          />
          <button
            type="submit"
            className="w-full bg-blue-500 text-white py-2 rounded-md hover:bg-blue-600 transition duration-300"
          >
            Backend İsteği Gönder
          </button>
        </form>
        {greeting && (
          <div className="mt-6 p-4 bg-gray-100 rounded-md">
            <p className="text-lg text-center text-gray-800">{greeting}</p>
          </div>
        )}
      </div>
    </div>
  );
}

export default App;