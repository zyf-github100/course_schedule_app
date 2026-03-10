const weeklySchedule = {
  '周一': [
    { time: '08:00 - 09:35', name: '高等数学', location: '2教 301', teacher: '李老师', color: 'purple' },
    { time: '14:00 - 15:35', name: '大学物理', location: '1教 402', teacher: '王老师', color: 'blue' }
  ],
  '周二': [
    { time: '10:00 - 11:35', name: '大学英语', location: '1教 205', teacher: '陈老师', color: 'green' },
    { time: '19:00 - 20:35', name: '程序设计基础', location: '机房 B203', teacher: '周老师', color: 'orange' }
  ],
  '周三': [
    { time: '08:00 - 09:35', name: '高等数学', location: '2教 301', teacher: '李老师', color: 'purple' },
    { time: '10:00 - 11:35', name: '大学英语', location: '1教 205', teacher: '陈老师', color: 'green' },
    { time: '14:00 - 15:35', name: '物理实验', location: '实验楼 A-102', teacher: '赵老师', color: 'red' },
    { time: '19:00 - 20:35', name: '数据结构', location: '线上课程', teacher: '刘老师', color: 'blue' }
  ],
  '周四': [
    { time: '08:00 - 09:35', name: '思想政治', location: '综合楼 101', teacher: '孙老师', color: 'teal' }
  ],
  '周五': [
    { time: '14:00 - 15:35', name: '体育', location: '操场', teacher: '何老师', color: 'green' },
    { time: '16:00 - 17:35', name: '计算机导论', location: '机房 A101', teacher: '吴老师', color: 'orange' }
  ],
  '周六': [],
  '周日': []
};

const summaryGrid = document.getElementById('week-summary-grid');
const scheduleBoard = document.getElementById('schedule-board');

Object.entries(weeklySchedule).forEach(([day, courses]) => {
  const summary = document.createElement('div');
  summary.className = `summary-card ${courses.length ? 'has-course' : 'is-empty'}`;
  summary.innerHTML = `
    <strong>${day}</strong>
    <span>${courses.length ? `${courses.length} 节课程` : '无课程'}</span>
  `;
  summaryGrid.appendChild(summary);

  const column = document.createElement('section');
  column.className = 'day-column';

  const itemsHtml = courses.length
    ? courses
        .map(
          course => `
            <article class="schedule-item ${course.color}">
              <div class="schedule-time">${course.time}</div>
              <div class="schedule-info">
                <strong>${course.name}</strong>
                <p>${course.location}</p>
                <small>${course.teacher}</small>
              </div>
            </article>
          `
        )
        .join('')
    : '<div class="empty-day">今天没有课程，好好休息。</div>';

  column.innerHTML = `
    <div class="day-header">
      <h4>${day}</h4>
      <span>${courses.length ? `${courses.length} 节` : '空闲'}</span>
    </div>
    <div class="day-items">${itemsHtml}</div>
  `;

  scheduleBoard.appendChild(column);
});
