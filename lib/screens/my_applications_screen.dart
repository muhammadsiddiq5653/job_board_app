import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/application_provider.dart';
import '../providers/user_provider.dart';
import '../models/application_model.dart';
import 'job_detail_screen.dart';

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({Key? key}) : super(key: key);

  @override
  _MyApplicationsScreenState createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch user applications when screen loads
    Future.microtask(() {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final applicationProvider =
          Provider.of<ApplicationProvider>(context, listen: false);

      if (userProvider.currentUser != null) {
        applicationProvider.getUserApplications(userProvider.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
      ),
      body: Consumer<ApplicationProvider>(
        builder: (context, applicationProvider, child) {
          if (applicationProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final applications = applicationProvider.userApplications;

          if (applications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.work_off_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No applications yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Apply for jobs to see them here',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final application = applications[index];
              return _buildApplicationCard(context, application);
            },
          );
        },
      ),
    );
  }

  Widget _buildApplicationCard(
      BuildContext context, JobApplication application) {
    // Get status color
    Color getStatusColor(ApplicationStatus status) {
      switch (status) {
        case ApplicationStatus.reviewed:
          return Colors.blue;
        case ApplicationStatus.interviewed:
          return Colors.orange;
        case ApplicationStatus.accepted:
          return Colors.green;
        case ApplicationStatus.rejected:
          return Colors.red;
        case ApplicationStatus.pending:
        default:
          return Colors.grey;
      }
    }

    // Format date
    String formatDate(DateTime date) {
      final month = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ][date.month - 1];

      return '$month ${date.day}, ${date.year}';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Navigate to job details
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobDetailScreen(jobId: application.jobId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      application.jobTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: getStatusColor(application.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      application.status.toString().split('.').last,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                application.companyName,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Applied on ${formatDate(application.appliedAt)}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
