const classes = [
  {
    time: '08:00 - 09:35',
    name: '高等数学',
    location: '2号教学楼 301',
    status: '即将开始'
  },
  {
    time: '10:00 - 11:35',
    name: '大学英语',
    location: '1号教学楼 205',
    status: '已排课'
  },
  {
    time: '14:00 - 15:35',
    name: '物理实验',
    location: '实验楼 A-102',
    status: '重要'
  },
  {
    time: '19:00 - 20:35',
    name: '数据结构',
    location: '线上课程',
    status: '晚间'
  }
];

const classList = document.getElementById('class-list');

classes.forEach(item => {
  const row = document.createElement('article');
  row.className = 'class-item';
  row.innerHTML = `
    <div class="class-time">${item.time}</div>
    <div class="class-meta">
      <strong>${item.name}</strong>
      <p>${item.location}</p>
    </div>
    <div class="status">${item.status}</div>
  `;
  classList.appendChild(row);
});
